// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#define SHARPENING 2 // Sharpening filter. [0 1 2]
#define CAS_AMOUNT 0.3 // Sharpening amount for CAS. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SSAO // Turn on for enhanced ambient occlusion (medium performance impact).
#define AOAmount 0.75	//[0.40 0.45 0.50 0.55 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.2 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define AOSamples 25 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200]
#define AO_BLUR_SAMPLES 16 //[4 8 16 32 64] //Number of AO blur samples.
#define AO_BLUR_RADIUS 2 //[1 2 3 4 5 6 7 8 9 10] //AO blur radius. Best not to change this.

#define AO_BLUR_SIZE 6 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define AO_BLUR_CLARITY 2.2 //[0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0]
#define AO_BLUR_WEIGHT 0.0

//#define COLOR_FILTER
#define COLOR_FILTER_RED 1.3
#define COLOR_FILTER_GREEN 1.2
#define COLOR_FILTER_BLUE 1.1
