#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>

#define OLED_RESET 2  //d4 pin on d1 mini
Adafruit_SSD1306 display(OLED_RESET);

#define DHTPIN 0      //d3 pin on d1 mini
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

void setup(){
  Serial.begin(9600);
  dht.begin();
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.display();
  delay(2000);
}

void loop(){

  display.clearDisplay();

  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  String tempstr = String(temp);
  String humstr = String(hum);

  //data check
  if (isnan(temp) || isnan(hum)){
    Serial.println("Failed to read data from DHT sensor");
  }

  display.setTextColor(WHITE);
  display.setTextSize(2);
  display.setCursor(0,0);
  display.println(tempstr+" C");
  display.println(humstr +" %");
  display.display();

  delay(10000); //sleep for 10 seconds
}
