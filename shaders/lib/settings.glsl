const int shadowMapResolution = 4096; //[256 512 1024 2048 4096]
const float sunPathRotation = 0.0f; //[-45.0f -40.0f -35.0f -30.0f -25.0f -20.0f -15.0f -10.0f -5.0f 0.0f 5.0f 10.0f 15.0f 20.0f 25.0f 30.0f 35.0f 40.0f 45.0f]

const int noiseTextureResolution = 128; // Default value is 64

#define SHADOWS
#define SHADOW_FILTER
#define COLORED_SHADOWS
#define SHADOW_SAMPLES 2 // [0 1 2 3 4 5 6 7 8 9 10]
#define SHADOW_BIAS 0.0001f