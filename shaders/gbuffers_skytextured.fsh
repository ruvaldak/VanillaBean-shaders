#version 120

uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

uniform sampler2D colortex4;

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	//Apply fog
	//#include "/lib/fog.glsl"

/* DRAWBUFFERS:049 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = color; //gcolor
	//gl_FragData[1] = fog;
	gl_FragData[2] = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}
