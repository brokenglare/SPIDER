#include <NovaBlinky.h>
#include <WS2812FX.h>
#include <NewPing.h>
/*
 * HC-SR04 example sketch
 *
 * https://create.arduino.cc/projecthub/Isaac100/getting-started-with-the-hc-sr04-ultrasonic-sensor-036380
 *
 * by Isaac100
 */
NovaBlinky nb;


#define LED_COUNT 3
#define LED_PIN 6

WS2812FX ws2812fx = WS2812FX(LED_COUNT, LED_PIN, NEO_RGB + NEO_KHZ800);
const int trigPin = 9;
const int echoPin = 10;
const int trigPin2 = 11;
const int echoPin2 = 12;

long duration, distance, Sensor1, Sensor2;

void setup() {
  nb.begin(); 
  ws2812fx.init();
  ws2812fx.setBrightness(255);
  ws2812fx.setSpeed(1000);
  ws2812fx.setColor(0xffffff);
  ws2812fx.setMode(FX_MODE_STATIC);
  ws2812fx.start();
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);
  Serial.begin(9600);
}

void loop() {
  nb.basicBlinkyLoop();
  ws2812fx.service();
  Sensor1 = SonarSensor(trigPin, echoPin);
  Sensor2 = SonarSensor(trigPin2, echoPin2);

  Serial.print("D, ");
  Serial.print(Sensor1);
  Serial.print(", ");
  Serial.println(Sensor2);
}

long SonarSensor(int trigPin,int echoPin)
{
digitalWrite(trigPin, LOW);
delayMicroseconds(2);
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);
duration = pulseIn(echoPin, HIGH);
return (duration/2) / 31;
 
}
