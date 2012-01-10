#include <math.h>

#include "WaveFlavours.h"

float midiToFreq(int midi_note) {
    // from https://gist.github.com/718095
    static const double half_step = 1.0594630943592953;  
    static const double midi_c0 = 8.175798915643707;
    
    return midi_c0 * pow(half_step, midi_note);
}

float calculatePitch(int n) {
    float freq = midiToFreq(n);
    float x = SAMPLE_RATE/freq;
    return TABLE_LEN/x;
}


// __PhaseCounter__________________________________________________________________________
//
void PhaseCounter::start(float d, float m) {
    x=0;
    oldX = 0;
    dx = d;
    max = m;
}

bool PhaseCounter::flipped() {
    if ((int)oldX == (int)x) { return false; }
    return true;
}

bool PhaseCounter::wrapped() {
    if (oldX > x) { return true; }
    return false;
}

int PhaseCounter::next() {
    oldX = x;
    x = x + dx;

    if (x < 0) { x = 0; }
    if (x >= max) { x = 0; }
    return (int)x;
}

void Voice::start(float* fm) {
    play.start(0,256);
    phaser.start(0.1,10101);
    freqMap = fm;  
}

int Voice::next(int wave1[]) {
    int c = play.next();
    int oset = (int)phaser.x;
 
    int x = wave1[c];
    int y = c+oset;
    while (y > 255) { y = y - 255; }
    int xp = wave1[y];
    return (x+xp)/2;
}


void Voice::setPhaserSpeed(float d) {
    phaser.dx = d;
}

void Voice::setPitch(int note) {
    play.dx = freqMap[note-30];
}

void Voice::fillMap() {
  for (int i=0;i<70;i++) {
    freqMap[i] = calculatePitch(i+30);
  }
}

