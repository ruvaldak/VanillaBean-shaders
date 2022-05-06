#version 120

#include "settings.glsl"

uniform sampler2D lightmap;

//0-1 amount of blindness.
uniform float blindness;

varying vec2 lmcoord;
varying vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
    vec4 fog;
	vec4 color = glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	//Apply fog
	doFog(color, fog, FOG_OFFSET_DEFAULT);
	
	//lolerror

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color * vec4(vec3(1.-blindness),1); //gcolor
	gl_FragData[1] = fog;
}
