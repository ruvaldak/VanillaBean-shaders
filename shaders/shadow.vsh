#version 120

#include "lib/distort.glsl"

attribute vec4 mc_Entity;

varying vec2 texcoord;
varying vec4 color;

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;


uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	vec3 modelPos = gl_Vertex.xyz;
	vec3 shadowViewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0f)).xyz;
	vec3 feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0f)).xyz;
	vec3 viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0f)).xyz;
	vec4 clipPos = gbufferProjection * vec4(viewPos, 1.0f);
	clipPos.xy = TAAJitter(clipPos.xy, clipPos.w);
	viewPos = (gbufferProjectionInverse * clipPos).xyz;
	feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0f)).xyz;
	shadowViewPos =  (shadowModelView * vec4(feetPlayerPos, 1.0f)).xyz;
	gl_Position = gl_ProjectionMatrix * vec4(shadowViewPos, 1.0f);

	gl_Position.xy = DistortPosition(gl_Position.xy);
	texcoord = gl_MultiTexCoord0.st;
	color = gl_Color;
}