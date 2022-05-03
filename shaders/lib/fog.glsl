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
uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform sampler2D noisetex;
uniform int frameCounter;

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

void doFog(inout vec4 col, inout vec4 fog) {
    if(fogMode == GL_EXP) //exponential fog
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR) //linear fog
        fog.a = clamp((gl_FogFragCoord-(gl_Fog.start+4.5)) * (gl_Fog.scale*1.25), 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0) {
        fog.a = clamp((gl_FogFragCoord-(gl_Fog.start+4.5)) * (gl_Fog.scale*1.25), 0., 1.);
        //fog.a = 1.-exp(-gl_FogFragCoord * (gl_Fog.density*2)); //denser underwater and underlava fog
    }
    
    //fog.rgb = gl_Fog.color.rgb;

    float x = interleavedGradientNoise(gl_FragCoord.xy, frameCounter*3);
    float y = interleavedGradientNoise(gl_FragCoord.xy, (frameCounter*3) + 1);
    float z = interleavedGradientNoise(gl_FragCoord.xy, (frameCounter*3) + 2);
    //vec4 dither = vec4(x,y,z, 1.0f);
    
    vec4 fogpos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
    vec4 dither = fract(texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution) + (1.0 / (0.5 + 0.5 * sqrt(5.0))) * (frameCounter & 127));
    //vec4 dither = interleavedGradientNoise(gl_FragCoord.xy, frameCounter);
    fogpos = (gbufferProjectionInverse * fogpos);
    fogpos.xy *= dither.xy;
    float upDot = dot(normalize(fogpos.xyz), gbufferModelView[1].xyz);
    fog.rgb = mix(skyColor, fogColor, (0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));

    //Apply the fog.
    col.rgb = mix(col.rgb, fog.rgb, fog.a);
}


/*float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}*/
