#version 120 

//Varyings//
varying vec2 texCoord;

//Uniforms//
uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

//Program//
void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}