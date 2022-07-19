#version 130

#include "settings.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
    vec4 fog;
	vec4 color = texture2D(texture, texcoord) * glcolor;

	doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
}
