#version 120

#include "lib/distort.glsl"

varying vec2 texcoord;
varying vec4 color;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

//#include "/bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();
	gl_Position.xy = DistortPosition(gl_Position.xy);
	texcoord = gl_MultiTexCoord0.st;
	color = gl_Color;

	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}