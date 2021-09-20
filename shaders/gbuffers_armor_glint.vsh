#version 120 

//Varyings//
varying vec2 texCoord;

varying vec4 color;

//Uniforms//
uniform int worldTime;

uniform float frameTimeCounter;

//Program//
void main(){
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();

	color = gl_Color;
}
