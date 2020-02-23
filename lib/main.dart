import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

String name = "Sensor not found";
String mac = "-";
String temp = "-";
String humm = "-";
String press = "-";
int rssi = 0;
String lasttime = "-";
int sec = 0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return MyHomePage();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer, _timer2;

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(const Duration(seconds: 10), startScan);
    _timer2 = new Timer.periodic(const Duration(seconds: 1), lastUpdate);

    FlutterBlue.instance.scanResults.listen((scanResults) {
      for (ScanResult scanResult in scanResults) {
        if (scanResult.device.name.toString() == "nrf52840.ru") {
          sec = 0;
          setState(() {
            rssi = scanResult.rssi;
            name = scanResult.device.name;
            mac = scanResult.device.id.toString();
            temp = scanResult.advertisementData.manufacturerData[256][0]
                    .toString() +
                "." +
                scanResult.advertisementData.manufacturerData[256][1]
                    .toString() +
                " °C";
            humm = scanResult.advertisementData.manufacturerData[256][2]
                    .toString() +
                "." +
                scanResult.advertisementData.manufacturerData[256][3]
                    .toString() +
                " %";
            press = scanResult.advertisementData.manufacturerData[256][4]
                    .toString() +
                "." +
                scanResult.advertisementData.manufacturerData[256][5]
                    .toString() +
                " kPa";
          });
          print(
              'Manufacturer data ${scanResult.advertisementData.manufacturerData}');
          FlutterBlue.instance.stopScan();
        }

        print(
            '${scanResult.device.name} found! mac: ${scanResult.device.id} rssi: ${scanResult.rssi}');
      }
    });
  }

  void startScan(Timer timer) {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 2));
  }

  void lastUpdate(Timer timer) {
    setState(() {
      lasttime = (sec++).toString() + " seconds ago";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    super.dispose();
  }

  static const String _title = 'Arduino sensor Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatelessWidget(),
      ),
    );
  }
}

List<int> tempList = [1, 2];

class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset('assets/images/sens.png'),
            title: Text('Sensor avaliable : '),
            subtitle: Text('$name rssi : $rssi'),
            trailing: Icon(Icons.signal_cellular_4_bar),
          ),
          ListTile(
            leading: Image.asset('assets/images/temp.png'),
            title: Text('Temperature : $temp'),
          ),
          ListTile(
            leading: Image.asset('assets/images/humm.png'),
            title: Text('Humidity : $humm'),
          ),
          ListTile(
            leading: Image.asset('assets/images/pres.png'),
            title: Text('Pressure : $press'),
          ),
          ListTile(
            leading: Icon(Icons.access_time, size: 55),
            title: Text('Last update: $lasttime'),
          ),
        ],
      ),
    );
  }
}
