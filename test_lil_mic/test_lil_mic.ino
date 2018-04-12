const int anPin = A0;
const int digiPin = 2;
float inputVal;
void setup() {
  pinMode(digiPin, INPUT);
  Serial.begin(9600);
}

void loop() {
  //inputVal = analogRead(anPin);
  //Serial.print("mic value: ");
  //Serial.println(inputVal);
  Serial.print("over thresh? : ");
  Serial.println(digitalRead(digiPin));
  delay(200);
}
