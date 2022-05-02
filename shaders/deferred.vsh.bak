#version 120

varying vec4 color;
varying vec2 texCoord;

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();

    color = gl_Color;
	texCoord = gl_MultiTexCoord0.xy;

	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
