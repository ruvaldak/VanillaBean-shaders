#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:09 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(gl_FragCoord.z, 0.0f, 0.0f, 1.0f); //gcolor
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}

#endif