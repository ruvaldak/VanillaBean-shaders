#version 130

varying vec2 texcoord;
varying vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main() {
	glcolor = gl_Color;
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	//if (clamp(texcoord, 0.0, 1.0) != texcoord) discard;
	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}