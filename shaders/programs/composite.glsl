#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform float frameTimeCounter;
uniform int frameCounter;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

/*
const int colortex0Format = R11F_G11F_B10F;
*/

in vec2 texcoord;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;
	
/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0f); //gcolor
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

uniform int frameCounter;

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif