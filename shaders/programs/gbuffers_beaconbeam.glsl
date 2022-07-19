#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D texture;

in vec2 texcoord;
in vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

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