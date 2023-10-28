#include <SoftwareSerial.h>
#include <TimerOne.h>

const int analogPin = A3;
SoftwareSerial bluetooth(10, 11);

const int numReadings = 20;

int readings[numReadings];  // the readings from the analog input
int total = 0;              // the running total
int average = 0;            // the average


float xn1 = 0.0;
float yn1 = 0.0;
float xn2 =0.0;


const int samplingFrequency = 30; // Sampling frequency in Hz
const long samplingInterval = 1000000 / samplingFrequency; // Sampling interval in microseconds


void setup() {
  
  pinMode(analogPin, INPUT); // Set analog pin as input
  Serial.begin(9600); // Initialize serial communication
  
  Timer1.initialize(samplingInterval); 
  Timer1.attachInterrupt(readPotentiometer);
  bluetooth.begin(9600); // Initialize Bluetooth communication

  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }


}
void loop() {

   
}

void readPotentiometer() {

  total = 0.0;
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = analogRead(analogPin);
    total = total + readings[thisReading];
  }
  
   average = total / numReadings;
   
  float xn = average;
   float yn = -0.02305471*yn1  + 0.51152736*xn +  0.51152736*xn1 + 0.0*xn2;
   xn2 = xn1;
   xn1 = xn;
   yn1 = yn;
   

    //Serial.print(xn);
    //Serial.print(" ");
  float angle = 0.41665476*yn-30.275;
   //Serial.println(angle);
   bluetooth.println(angle);
   
}
