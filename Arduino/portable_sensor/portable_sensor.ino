#include <ArduinoBLE.h>
#include <Arduino_HTS221.h>
#include <Arduino_LPS22HB.h>

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);

  if (!BARO.begin()) {
    Serial.println("Failed to initialize pressure sensor!");
    while (1);
  }
  
  if (!HTS.begin()) {
    Serial.println("Failed to initialize humidity temperature sensor!");
    while (1);
  }
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }
  BLE.setLocalName("nrf52840.ru");
  BLE.setConnectable(false);
  byte data[8] = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};

  BLE.setManufacturerData(data, 8);
  // start advertising
  BLE.advertise();

  Serial.println("Bluetooth device active...");
}

void loop() {
  BLE.stopAdvertise();
   // read all the sensor values
  float temperature = HTS.readTemperature();
  float humidity    = HTS.readHumidity();
  float pressure = BARO.readPressure();

  String temp1 = "";
  String temp2 = "";
  String humm1 = "";
  String humm2 = "";
  String pres1 = "";
  String pres2 = "";

  //Temperature
  temp1 = String(temperature);
  temp2 = String(temperature);
  int dotInTemp = temp1.indexOf('.');
  temp1.remove(dotInTemp);
  temp2.remove(0, dotInTemp+1);
  Serial.println(temp1 + "."+ temp2 + " °C");
  byte t1 = temp1.toInt();
  byte t2 = temp2.toInt();

  //Humidity 
  humm1 = String(humidity);
  humm2 = String(humidity);
  int dotInHum = humm1.indexOf('.');
  humm1.remove(dotInHum);
  humm2.remove(0, dotInHum+1);
  Serial.println(humm1 + "." + humm2 + " %");
  byte h1 = humm1.toInt();
  byte h2 = humm2.toInt();

  //Pressure
  pres1 = String(pressure);
  pres2 = String(pressure);
  int dotInPre = pres1.indexOf('.');
  pres1.remove(dotInPre);
  pres2.remove(0, dotInPre+1);
  Serial.println(pres1 + "." + pres2 + " kPa");
  byte p1 = pres1.toInt();
  byte p2 = pres2.toInt();

  Serial.println();
  
  byte data[8] = { 0x00, 0x01, t1, t2, h1, h2, p1, p2};
  BLE.setManufacturerData(data, 8);
  BLE.advertise();
  // wait 1 second to print again
  delay(2000);
}
