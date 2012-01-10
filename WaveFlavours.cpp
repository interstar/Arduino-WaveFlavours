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


