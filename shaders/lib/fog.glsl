/*
Only works in GBuffers
Requires these things to be set before the main function:

//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;
*/
/*vec4 fogpos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
fogpos = gbufferProjectionInverse * fogpos;
float upDot = dot(normalize(fogpos.xyz), gbufferModelView[1].xyz);
fog.rgb = mix(skyColor, fogColor, 0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));*/

/*fogify(float x, float w) = w / (x * x + w)

0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)

fogify(max(upDot, 0.0), 0.25) = 0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25);*/


//0 = default, 1 = water, 2 = lava.
//#extension GL_EXT_gpu_shader4: enable

uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform sampler2D noisetex;
uniform int frameCounter;
uniform sampler2D colortex4;
uniform sampler2D colortex7;
//0-1 amount of blindness.
uniform float blindness;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

const int noiseTextureResolution = 128;

float interleavedGradientNoise(vec2 pos) {
    return fract(52.9829189 * fract(0.06711056 * pos.x + (0.00583715 * pos.y)));
}

float interleavedGradientNoise(vec2 pos, int t) {
    return interleavedGradientNoise(pos + 5.588238 * (t & 127));
}

void doFog(inout vec4 col, inout vec4 fog, float offset) {
    vec4 skyTexture = texture2D(colortex4, gl_FragCoord.xy / vec2(viewWidth, viewHeight));
    vec3 skyCol = texture2D(colortex7, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).rgb;

    if(fogMode == GL_EXP) //exponential fog
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR || isEyeInWater == 1.0 || isEyeInWater == 2.0) //linear fog
        fog.a = clamp((gl_FogFragCoord-(gl_Fog.start+offset)) * (gl_Fog.scale), 0., 1.);

    
    vec4 fogpos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
    //vec4 dither = fract(texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution) + (1.0 / (0.5 + 0.5 * sqrt(5.0))) * (frameCounter & 127));
    float dither = interleavedGradientNoise(gl_FragCoord.xy, frameCounter);
    fogpos = (gbufferProjectionInverse * fogpos);
    //fogpos.xy *= dither.xy;
    float upDot = dot(normalize(fogpos.xyz), gbufferModelView[1].xyz);
    #ifdef NETHER
        fog.rgb = mix(skyColor, fogColor, (0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));
    #else
        fog.rgb = mix(skyColor, skyCol, (0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));
    #endif

    if(blindness > 0.0) {
        fog.rgb -= blindness;
    }

    /*if (!(isEyeInWater == 1.0 || isEyeInWater == 2.0))
        fog.rgb += skyTexture.rgb;//*/

    //Apply the fog
    col.rgb = mix(col.rgb, fog.rgb, fog.a);
    col += (dither) / 255.0f;
}
