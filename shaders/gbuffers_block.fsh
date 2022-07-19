#version 130

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:09 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(gl_FragCoord.z, 0.0f, 0.0f, 1.0f); //gcolor
}