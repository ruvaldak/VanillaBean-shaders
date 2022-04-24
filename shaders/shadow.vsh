#version 120

#include "lib/distort.glsl"

varying vec2 texcoord;
varying vec4 color;

void main() {
	gl_Position = ftransform();
	gl_Position.xy = DistortPosition(gl_Position.xy);
	texcoord = gl_MultiTexCoord0.st;
	color = gl_Color;
}