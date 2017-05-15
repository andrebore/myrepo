#include <wiringPi.h>

int main(void){
wiringPiSetup();
wiringPiSetupGpio();

pinMode(15, INPUT);
pinMode(15, OUTPUT);

digitalWrite(15, HIGH);
delay(3000);
digitalWrite(15, LOW);
}
