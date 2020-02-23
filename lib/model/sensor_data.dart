class SensorData {
  final String name;
  final int rssi;
  final String mac;
  final double temperature;
  final double humidity;
  final double pressure;
  final DateTime lastTime;

  SensorData(
      {this.name,
      this.rssi,
      this.mac,
      this.temperature,
      this.humidity,
      this.pressure,
      DateTime lastTime})
      : this.lastTime = lastTime ?? DateTime.now();
}
