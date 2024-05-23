// Serial Write demo

volatile unsigned long start = millis();
volatile unsigned long interval = 500;

void setup() {
  Serial.begin(115200);
}

void loop() {
  static uint8_t n = 0;
  if((millis() - start) > interval){
    Serial.println(n ^ (n >> 1));
    Serial.flush();
    n ++;
    start = millis();
  }
}
