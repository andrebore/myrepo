#include <DHT.h>
#include <ESP8266WiFi.h>

/* DHT Pro Shield
 * Depends on Adafruit DHT Arduino library
 * https://github.com/adafruit/DHT-sensor-library
 */

/*Rooms list
 * 1 - Livingroom
 * 2 - Kitchen
 * 3 - Office
 * 4 - Wardrobe
 * 5 - Bedroom
 * 6 - Bath
 * 7 - Balcony
*/

#define DHTPIN 2 // PIN connected to the sensor - refer to https://wiki.wemos.cc/products:d1:d1_mini for PINs map

// select the correct sensor
//#define DHTTYPE DHT11   // DHT 11
#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)

// WiFi details
const char* ssid = "insert ssid here";
const char* pass = "insert password here";

//some other vars
int i = 0;

// sensor instance
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  Serial.println("D1 board started");

  //WiFi connection
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting...");
  }
  Serial.println("Got IP: ");
  Serial.print(WiFi.localIP());
  Serial.println();
  Serial.println("Sensor is starting up");

  while ( i <= 500) {
    Serial.print(".");
    i ++;
  }


  // startup the sensor
  dht.begin();
  delay(5000);
}

void loop(){
  //read temperature
  float temp = dht.readTemperature();

  //read humidity
  float humidity = dht.readHumidity();

  //data check
  if (isnan(temp) || isnan(humidity)){
    Serial.println("Failed to read data from DHT sensor");
  }

  //write out data to serial
  Serial.print("Temperature: ");
  Serial.print(temp);
  Serial.print("*C ");
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println("%\t");

//send data to web server for logging
  WiFiClient client;
    if (!client.connect("web server ip here", 8080)) {  //use the right web server port
    Serial.println("Conection Fail");
    return;
  }

  // assembling url for GET request - change r depending on the room
  String url = "GET /?lastread&r=1&t=";
  url += temp;
  url += "&h=";
  url += humidity;
  url += " HTTP/1.1\r\n";

  //send GET request
  client.println(url);

  //write out url for debug
  Serial.println("Generating GET request...");
  Serial.print(url);
  Serial.println("data sent - OK!");

  //wait 2 seconds before sleep
  delay(2000);

  //deep slep (30 minutes - DHT library accepts deep sleep time in microsecond. multiply the desired deep slepp time in second * 100000)
  Serial.println("Sending deep sleep command");
  Serial.println("...");
  Serial.println("Sleeping for 30 minutes");
  ESP.deepSleep(1800*1000000);
}
