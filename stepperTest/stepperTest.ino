#include <AFMotor.h>

// Connect a stepper motor with 48 steps per revolution (7.5 degree)
// to motor port #2 (M3 and M4)
AF_Stepper motor(48, 2);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Stepper test!");

  motor.setSpeed(150);  // 50 rpm   
}

void loop() {
  Serial.println("Double coil steps\n");
  motor.step(500, FORWARD, DOUBLE);
  //motor.step(500, BACKWARD, DOUBLE);

  //Serial.println("Interleaved steps\n");
  //motor.step(100, FORWARD, INTERLEAVE);

  delay(1000);
}
