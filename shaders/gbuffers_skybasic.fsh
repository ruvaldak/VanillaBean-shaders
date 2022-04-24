#version 120

#include "lib/settings.glsl"

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
varying vec3 normal;

varying vec4 glcolor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

void main() {
	vec4 color = glcolor;
	vec4 fog;
	if (starData.a > 0.5) {
		color = vec4(starData.rgb, 1.0);
		//vec4 fog = vec4(1.0,1.0,1.0,1.0);
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = vec4(calcSkyColor(normalize(pos.xyz)),1.0);
	}

/* DRAWBUFFERS:01 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(normal, 1.0f);
}
