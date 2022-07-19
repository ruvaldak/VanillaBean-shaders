#version 120

#include "settings.glsl"

uniform vec3 sunPosition;

uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

//uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec3 bufferNormal;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float entity;

//fix artifacts when colored shadows are enabled
const bool shadowcolor0Nearest = true;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

//0-1 amount of blindness.
uniform float blindness;

#include "/lib/fog.glsl"

#define SHADOW_SAMPLES_COUNT 2

void main() {	
    vec4 color = glcolor * texture2D(texture,texcoord);
    vec2 lm = lmcoord;
	
	//Combine lightmap with blindness.
    vec3 light = (1.-blindness) * texture2D(lightmap,lm).rgb;
	color *= vec4(light,1);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog;
	doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03689 */
	gl_FragData[0] = color; //gcolor
	//gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[1] = fog;
	//gl_FragData[2] = vec4(shadowSamples);
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(bufferNormal * 0.5f + 0.5f, 1.0f);
	gl_FragData[4] = vec4(gl_FragCoord.z, 0.0f, 0.0f, 1.0f);
}
