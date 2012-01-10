#include <math.h>

#include "WaveFlavours.h"

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

void Voice::start() {
    play.start(0,255);
    phaser.start(0.001,10101);
}

int Voice::next(int wave1[]) {
    int c = play.next();
    int oset = phaser.next();
 
    int x = wave1[c];
    int xp = wave1[(c+oset)%255];
    return (x+xp)/2;
}


void Voice::setPhaserSpeed(float d) {
    phaser.dx = d;
}

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

void Voice::setPitch(int note) {
    play.dx = calculatePitch(note);
}
