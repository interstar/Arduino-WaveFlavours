Arduino WaveFlavours
====================

WaveFlavours is a simple synthesis technique to get an interesting evolving sound using very little processing power. The idea is to play sounds from a couple of wavetables and to make minor changes over the evolution of the sound. For example, swapping sample values between two different tables or reversing the wave shape, one pair of sample points at a time.

More information about WaveFlavours can be found here : https://github.com/interstar/WaveFlavours 

On An Arduino?
--------------
What's interesting about this technique is that it should be adaptable to low-power embedded devices. In particular, I wanted to see if I could get music synthesis on my Arduino. 

The circuitry should be fairly simple, I take audio output from pin 11, while pitch input is on analog pin 0. Analog pins 1, 2 and 3 control three of the forms of "modulation" and digital input pin 12 is used to toggle between monophonic and a chord output.

Examples
--------

A rich drone : http://soundcloud.com/mentufacturer/arduino-waveflavour-drone
