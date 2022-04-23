#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;

void main() {
	//use texture matrix instead of dividing by 15 to maintain compatibility
	lmcoord = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
	//transform to [0, 1] range
	lmcoord = (lmcoord * 33.05f / 32.0f) - (1.0f / 32.0f);

	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.st;
	normal = gl_NormalMatrix * gl_Normal;
	color = gl_Color;
}