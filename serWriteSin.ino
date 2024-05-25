

const PROGMEM uint8_t sinData[] = {
128,131,134,137,140,144,147,150,
153,156,159,162,165,168,171,174,
177,180,182,185,188,191,193,196,
199,201,204,206,209,211,213,216,
218,220,222,224,226,228,230,232,
234,235,237,239,240,242,243,244,
245,247,248,249,250,250,251,252,
253,253,254,254,254,255,255,255,
255,255,255,255,254,254,254,253,
253,252,251,250,249,249,247,246,
245,244,243,241,240,238,237,235,
233,232,230,228,226,224,222,220,
218,215,213,211,208,206,203,201,
198,196,193,190,188,185,182,179,
176,173,170,167,164,161,158,155,
152,149,146,143,140,137,134,131,
128,124,121,118,115,112,109,106,
103,100,97,94,91,88,85,82,
79,76,73,70,68,65,62,60,
57,54,52,49,47,45,42,40,
38,36,34,31,29,28,26,24,
22,20,19,17,16,14,13,12,
10,9,8,7,6,5,5,4,
3,3,2,2,2,1,1,1,
1,1,1,1,2,2,2,3,
4,4,5,6,7,8,9,10,
11,12,14,15,16,18,19,21,
23,25,26,28,30,32,34,37,
39,41,43,46,48,51,53,56,
58,61,63,66,69,72,74,77,
80,83,86,89,92,95,98,101,
104,107,110,113,116,120,123,126};

volatile unsigned long start = millis();
volatile unsigned long interval = 10;

void setup() {
  Serial.begin(115200);
}

void loop() {
  static uint8_t n = 0;
  if((millis() - start) > interval){
    uint8_t data = pgm_read_byte_near(sinData + n);
    Serial.println(data);
    Serial.flush();
    n ++;
    start = millis();
  }
}
