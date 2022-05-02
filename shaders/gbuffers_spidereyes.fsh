#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec4 fog;
	doFog(color, fog);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
