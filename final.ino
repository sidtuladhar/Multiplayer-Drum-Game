#include "SerialRecord.h"

SerialRecord writer(3);

void setup() {
  Serial.begin(9600);
}

void loop() {
  
  int value1 = analogRead(0);
  int value2 = analogRead(2);
  int value3 = analogRead(4);
  writer.send();
  //if (value1 > 0) {
  writer[0] = value1;
  writer[1] = value2;
  writer[2] = value3;
    //writer.send(0);
      //
  //}
  //if (value2 > 0) {
  
  
      //
  //}
  
  // This delay slows down the loop, so that it runs less frequently. This can
  // make it easier to debug the sketch, because new values are printed at a
  // slower rate.
  delay(20);
  
}
