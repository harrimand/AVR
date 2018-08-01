
void readA0();

const int DirPin = 4;
const int PWMpin = 3;
const int DirLED = 13;
int DC = 0;
long delStart = millis();

void setup() {
  Serial.begin(9600);
  OCR2A = 249;
  OCR2B = 1;
  TCCR2A = (1 << COM2B1)|(1 << WGM21)|(1 << WGM20);
  TCCR2B = (1 << WGM22)|(1 << CS22)|(1 << CS20);
  pinMode(PWMpin, OUTPUT);
  pinMode(DirPin, OUTPUT);
  pinMode(A0, INPUT);
  PORTD = 0;
}

void loop() {
  if ((delStart + 100) <  millis()){
    readA0();
    delStart = millis();
  }
}
/*
void serialEvent(){
  if(Serial.available()){
    delay(5);
    int DC = Serial.parseInt();
    Serial.read();
    Serial.print("Duty Cycle: ");
    Serial.print(DC);
    if (DC > -4 && DC < 4){
      OCR2B = 0;
      digitalWrite(DirPin, LOW);
      digitalWrite(DirLED, LOW);
      Serial.println("  Stopped");
    }
    else if (DC < -3 ){
      OCR2B = map(byte(abs(DC)), 0, 100, 0, 249);
      digitalWrite(DirPin, LOW);
      digitalWrite(DirLED, LOW);
      Serial.println("  Left");
    }
    else {
      OCR2B = map(byte(abs(DC)), 0, 100, 0, 249);
      digitalWrite(DirPin, HIGH);
      digitalWrite(DirLED, HIGH);
      Serial.println("  Right");
    }
  }
}
*/
void readA0(){
  int senseVal = analogRead(A0);
  if (senseVal < 500){
    byte compareVal = byte(map(500-senseVal, 0, 500, 0, 249));
    OCR2B = compareVal;
    digitalWrite(DirPin, LOW);
    digitalWrite(DirLED, LOW);
    Serial.print("  Left  ");
    Serial.println(compareVal);
  }

  else if (senseVal > 523){
    byte compareVal = byte(map(senseVal-523 , 0, 500, 0, 249));
    OCR2B = compareVal;
    digitalWrite(DirPin, HIGH);
    digitalWrite(DirLED, HIGH);
    Serial.print("  Right  ");
    Serial.println(compareVal);
  }
  
  else {
    OCR2B = 0;
    digitalWrite(DirPin, LOW);
    digitalWrite(DirLED, LOW);
    Serial.println("  Stopped");
  }
}






















