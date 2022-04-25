#version 120

varying vec2 texcoord;
varying vec4 color;

uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

//#include "/bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.st;

	color = gl_Color;

	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}