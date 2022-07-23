#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/fog.glsl"
#include "/settings.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

	vec4 fog = vec4(1.0);
    doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}

#endif