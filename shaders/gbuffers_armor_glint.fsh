#version 130

#include "settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	vec4 fog;
	doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}
