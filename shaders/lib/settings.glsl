const int shadowMapResolution = 4096; //[256 512 1024 2048 4096]
const float sunPathRotation = 0.0f; //[-45.0f -40.0f -35.0f -30.0f -25.0f -20.0f -15.0f -10.0f -5.0f 0.0f 5.0f 10.0f 15.0f 20.0f 25.0f 30.0f 35.0f 40.0f 45.0f]

const int noiseTextureResolution = 128; // Default value is 64

#define SHARPENING 2 // [0 1 2]
#define CAS_AMOUNT 0.4 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define SHADOWS
#define SHADOW_FILTER
#define COLORED_SHADOWS
#define SHADOW_SAMPLES 2 // [0 1 2 3 4 5 6 7 8 9 10]
#define SHADOW_BIAS 0.0001f

#define SSAO
#define AO_TYPE 2 //[1 2]
#define AOAmount 1.0	//[0.40 0.45 0.50 0.55 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.2 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define AOSamples 20 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200]

#define AO_BLUR_SIZE 6 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define AO_BLUR_CLARITY 2.2 //[0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0]
#define AO_BLUR_WEIGHT 0.0

//#define BLUR_GLASS