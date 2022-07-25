#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/lib/color.glsl"

uniform sampler2D texture;
/*
const int colortex0Format = R11F_G11F_B10F;
*/

in vec2 texcoord;
in vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color.rgb = sRGBToLinear(color.rgb);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

out vec2 texcoord;
out vec4 glcolor;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}

#endif