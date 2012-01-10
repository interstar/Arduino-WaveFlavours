#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <math.h>

#include "WaveFlavours.h"


int speakerPin = 11;
int buttonPin = 12;

int pitchPin = 0;
int modPin = 1;

int tempo = 100;
int pitchRead, oldPitchRead, pitch;
float freq;

int wave1[TABLE_LEN];
int wave2[TABLE_LEN];

float freqMap[70];

boolean poly;
int debounce;

PhaseCounter swapTimer, swapCounter, revTimer, revCounter;
Voice v1,v2,v3;

// This is called at 8000 Hz to load the next sample. (Like audioRequested in openFrameworks)
// Thanks to http://www.arduino.cc/playground/Code/PCMAudio for details of how to do this interupt 
ISR(TIMER1_COMPA_vect) {
  static int v;
  if (poly) {
    v = v1.next(wave1) + v2.next(wave1) + v3.next(wave1);
    v = v/3;
  } 
  else {
    v = v1.next(wave1);
  }
  OCR2A = v;
}

void fillWaves() {
  float da = (2 * 3.1415) / 256.0;
  float a = 0;
  for (int i=0;i<256;i++) {
    wave1[i]=i;
    wave2[i]=(int)(sin(a)*256)+128;
    a = a + da;
  }
}


void setup() {
  pinMode(speakerPin,OUTPUT);
  pinMode(buttonPin,INPUT);
  fillWaves();  
  Serial.begin(9600);       

  poly = false;  // set to true for 3 voice chord
  v1.start(freqMap);  
  v1.fillMap();
  v2.start(freqMap); // even if voices 2 & 3 aren't used, we set them up anyway
  v3.start(freqMap);

  swapTimer.start(0.01,1000);
  swapCounter.start(1,255);    
  revTimer.start(0,10000);
  revCounter.start(1,255);

  debounce = 0;



  // Set up the interupt  
  // Set up Timer 2 to do pulse width modulation on the speaker pin.

  // Use internal clock (datasheet p.160)
  ASSR &= ~(_BV(EXCLK) | _BV(AS2));

  // Set fast PWM mode  (p.157)
  TCCR2A |= _BV(WGM21) | _BV(WGM20);
  TCCR2B &= ~_BV(WGM22);

  // Do non-inverting PWM on pin OC2A (p.155)
  // On the Arduino this is pin 11.
  TCCR2A = (TCCR2A | _BV(COM2A1)) & ~_BV(COM2A0);
  TCCR2A &= ~(_BV(COM2B1) | _BV(COM2B0));

  // No prescaler (p.158)
  TCCR2B = (TCCR2B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

  // Set initial pulse width to the first sample.
  OCR2A = 0;

  // Set up Timer 1 to send a sample every interrupt.
  cli();

  // Set CTC mode (Clear Timer on Compare Match) (p.133)
  // Have to set OCR1A *after*, otherwise it gets reset to 0!
  TCCR1B = (TCCR1B & ~_BV(WGM13)) | _BV(WGM12);
  TCCR1A = TCCR1A & ~(_BV(WGM11) | _BV(WGM10));

  // No prescaler (p.134)
  TCCR1B = (TCCR1B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

  // Set the compare register (OCR1A).
  // OCR1A is a 16-bit register, so we have to do this with
  // interrupts disabled to be safe.
  OCR1A = F_CPU / SAMPLE_RATE;    // 16e6 / 8000 = 2000

  // Enable interrupt when TCNT1 == OCR1A (p.136)
  TIMSK1 |= _BV(OCIE1A);

  sei(); 

}


void loop() {
  int c,x;
  pitchRead = analogRead(pitchPin);
  if (pitchRead != oldPitchRead) {
    pitch = map(pitchRead,0,1023,30,100);
    //Serial.println(pitch);

    v1.setPitch(pitch);
    v2.setPitch(pitch+5);
    v3.setPitch(pitch+12);
    oldPitchRead = pitchRead;
  }

  v1.phaserNext();
  v2.phaserNext();
  v3.phaserNext();

  float p1 =(analogRead(1))*0.1;
  revTimer.dx = p1;

  revTimer.next();
  if (revTimer.wrapped()) {
    c = revCounter.next();
    x = wave1[c];
    wave1[c] = wave1[255-c];
    wave1[255-c]=x;
  }

  swapTimer.next();
  if (swapTimer.wrapped()) { 
    c = swapCounter.next();
    x = wave2[c];
    wave2[c]=wave1[c];
    wave1[c]=x;
  }  

  if (debounce<=0) {
    if (digitalRead(buttonPin)==HIGH) {
      poly = !poly;
      debounce = 100;
      Serial.println("button");
    }
  } else {
    debounce--;
  }  

}

