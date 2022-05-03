#version 120

uniform sampler2D texture;
uniform sampler2D colortex4;

varying vec2 texcoord;
varying vec4 glcolor;

//#include "/lib/fog.glsl"



uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform sampler2D noisetex;
uniform int frameCounter;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

const int noiseTextureResolution = 128;

varying vec3 playerPos;

vec4 skyTexture = texture2D(colortex4, gl_FragCoord.xy / vec2(viewWidth, viewHeight));

void doFog(inout vec4 col, inout vec4 fog) {
    if(fogMode == GL_EXP) //exponential fog
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR) //linear fog
        fog.a = clamp((gl_FogFragCoord-(gl_Fog.start+50.0)) * gl_Fog.scale, 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density); //denser underwater and underlava fog
    
    vec4 fogpos = vec4((gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0), 1.0, 1.0);
    vec4 dither = fract(texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution) + (1.0 / (0.5 + 0.5 * sqrt(5.0))) * (frameCounter & 127));
    fogpos = (gbufferProjectionInverse * fogpos);
    fogpos.xy *= dither.xy;

    float upDot = dot(normalize(fogpos.xyz), gbufferModelView[1].xyz);
    //fog.rgb = mix(skyColor, fogColor, (0.25 / max(length(playerPos.xz), abs(playerPos.y))) * (0.25 / max(length(playerPos.xz), abs(playerPos.y))) + 0.25);
    fog.rgb = mix(skyColor, fogColor, (0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));

    //fog.a = clamp(max(length(playerPos.xz), abs(playerPos.y)), 0., 1.);
    fog.rgb += (skyTexture.rgb);
    col.rgb = mix(col.rgb, fog.rgb, fog.a);
}



void main() {
    vec4 fog;
	vec4 color = texture2D(texture, texcoord) * glcolor;

	doFog(color, fog);

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
}
