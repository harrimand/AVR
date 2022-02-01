// C++ code
// Quadrature Encoder signal generation using timer 1 and decoding 
// using Pin Change Interrupts PCI0 and PCI2.
// Using two different ports to minimize required testing on interrupts.
// Connect wires from Mega Pins 11..12 to Pins 53..52 for PCI0 counter.
// Connect wires from Mega Pins 11..12 to Pins A15..A14 for PCI2 counter.
// Reversing wires will reverse count direction.
// Pin 3 (Interrupt 5) with pullup enabled can be grounded momentarily to
//   run interrupt service routine (ISR) that swaps OCR1A and OCR1B values 
//   to change phase of OC1A and OC1B which reverses direction of count.
//
// Waveform toggles once each Timer 1 count from 0 to Top.
// Each cycle has 2 toggles.

#define GrayPeriod .1 // Grey Code Period = 1/(2 * Frequency)
#define T1top GrayPeriod / .000032  // 16 MHz MCU clock
#define PulseA T1top / 4 // Toggle Pulse at 1/4 count
#define PulseB 3 * T1top / 4 // Toggle Pulse at 3/4 count

volatile long int enCount0 = 0L;
volatile long int enCount2 = 0L;
volatile bool newEnc0 = false;
volatile bool newEnc2 = false;

void setup()
{
  Serial.begin(115200);
  // Configure Input and Output pins.
  DDRB = DDRB | 0x60 ;  //Mega Pins 11 (OC1A) and 12 (OC1B) Output
  DDRB = DDRB & 0xFC ; //Mega Pin 52 PB1 and Pin 53 PB0 Encoder Input
  DDRK = DDRK & 0xFC; //Mega PK7 (Pin A15) and PK6 (Pin A14) Input for encoder
  DDRE = DDRE & 0xDF; // Mega Pin 3 External Interrupt 5 input
  PORTE = PORTE | 0x20; // Mega Pin 3 Pull-Up Resistor Enabled

  //--- Pin Change Interrupt 0 and 2 used for quadrature encoder inputs. ---
  PCMSK0 = (1<<PCINT1)|(1<<PCINT0); // Encoder 0 Inputs Mega Pins 53 and 52
  PCMSK2 = (1<<PCINT23)|(1<<PCINT22); // Encoder 2 Inputs Pins A15 and A14
  PCICR = (1<<PCIE2)|(1<<PCIE0); // Enable Pin Change Interrupts 2 and 0

  
  //---Generate Gray Code Output on OC1A and OC1B so simulate encoder signals---
  //---  OC1A..B are +/- 90 degrees out of phase using Waveform Generation CTC Mode 12. ---
  //---  Compare Output Modes set to toggle pins on compare match. ---
  TCCR1A = 0;   // Clear config to allow immediate updates of registers.
  TCCR1B = 0;
  ICR1 = T1top;
  OCR1A = PulseA; // Toggle on compare match at .25 * ICR1 value
  OCR1B = PulseB; // Toggle on compare match at .75 * ICR1 value
  TCCR1A = (0<<COM1A1)|(1<<COM1A0)|(0<<COM1B1)|(1<<COM1B0)|(0<<WGM11)|(0<<WGM10);
  //TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(0<<CS11)|(0<<CS10);
  TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(0<<CS11)|(1<<CS10); //For testing

//----External Interrupt Pin to change OC1A..B Phase to +90/-90 -------------
  EICRB = (1<<ISC51)|(0<<ISC50);
  EIMSK = (1<<INT5);
  
  Serial.print("OCR1A: ");
  Serial.println(OCR1A);
  Serial.print("OCR1B: ");
  Serial.println(OCR1B);
}

void loop()
{
  
  if(newEnc0)
  {
    Serial.print("Count 0: ");
    Serial.println(enCount0);
    newEnc0 = false;
  }  
  if(newEnc2)
  {
    Serial.print("Count 2: ");
    Serial.println(enCount2);
    newEnc2 = false;
  }
}


ISR(PCINT2_vect) //PortK PK0..PK1 Mega Pins A8..A9
{
  static uint8_t preSig2 = 0; // Declare variable first time
  // Determine which pin triggered interrupt using XOR.
  uint8_t Enc2 = PINK & 0xC0;
  uint8_t EncAB = Enc2 ^ preSig2;
  switch (EncAB)
  {
    case 0x80:  // Pin PK7 (A15) Changed
      enCount2 += (Enc2 == 0xC0 || Enc2 == 0x00) ? 1: -1;
      break;
    case 0x40:  // Pin PK6 (A14) Changed
      enCount2 += (Enc2 == 0xC0 || Enc2 == 0x00) ? -1: 1;
        break;
  }
  preSig2 = Enc2;
  newEnc2 = true;
}

ISR(PCINT0_vect) //PortB Mega Pins 53..52
{
  static uint8_t preSig0 = 0; // Declare variable first time
  // Determine which pin triggered interrupt using XOR.
  uint8_t Enc0 = PINB & 0x03;
  uint8_t EncAB = Enc0 ^ preSig0;
  switch (EncAB)
  {
    case 0x01:  // Pin PB0 (53) Changed
      enCount0 += (Enc0 == 0x03 || Enc0 == 0x00) ? 1: -1;
      break;
    case 0x02:  // Pin PB1 (52) Changed
      enCount0 += (Enc0 == 0x03 || Enc0 == 0x00) ? -1: 1;
        break;
  }
  preSig0 = Enc0;
  newEnc0 = true;
}

ISR(INT5_vect)
{
    // Swapping OCR1A and OCR1B values changes phases of 
    // OC1A and OC1B to +/- 90 deg.
    unsigned int temp = OCR1B;
    OCR1B = OCR1A;
    OCR1A = temp;
}
