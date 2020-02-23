import 'dart:async';

import 'package:arduino_ble_sensor/model/sensor_data.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScanner {
  Timer _timer;
  StreamController<SensorData> _streamController = new StreamController();
  Stream<SensorData> get sensorData => _streamController.stream;

  DeviceScanner() {
    _subscribeToScanEvents();
    _timer = new Timer.periodic(const Duration(seconds: 10), startScan);
  }

  void startScan(Timer timer) {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 2));
  }

  void dispose() {
    _timer.cancel();
    _streamController.close();
  }

  void _subscribeToScanEvents() {
    FlutterBlue.instance.scanResults.listen((scanResults) {
      for (ScanResult scanResult in scanResults) {
        if (scanResult.device.name.toString() == "nrf52840.ru") {
          final int rssi = scanResult.rssi;
          final String name = scanResult.device.name;
          final String mac = scanResult.device.id.toString();
          final double temp = scanResult.advertisementData.manufacturerData[256]
                  [0] +
              scanResult.advertisementData.manufacturerData[256][1] * 0.01;
          final double humm = scanResult.advertisementData.manufacturerData[256]
                  [2] +
              scanResult.advertisementData.manufacturerData[256][3] * 0.01;
          final double press =
              scanResult.advertisementData.manufacturerData[256][4] +
                  scanResult.advertisementData.manufacturerData[256][5] * 0.01;
          final SensorData sensorData = new SensorData(
              name: name,
              rssi: rssi,
              mac: mac,
              temperature: temp,
              humidity: humm,
              pressure: press);
          _streamController.add(sensorData);
          print(
              'Manufacturer data ${scanResult.advertisementData.manufacturerData}');
          FlutterBlue.instance.stopScan();
        }

        print(
            '${scanResult.device.name} found! mac: ${scanResult.device.id} rssi: ${scanResult.rssi}');
      }
    });
  }
}
