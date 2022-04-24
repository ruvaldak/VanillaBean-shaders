#version 120

uniform sampler2D lightmap;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;

uniform sampler2D texture;

void main() {
	vec4 albedo = texture2D(texture, texcoord);

	/* DRAWBUFFERS:0123 */
	gl_FragData[0] = albedo;
	gl_FragData[1] = vec4(normal, 1.0f);
	gl_FragData[2] = vec4(texture2D(lightmap,lmcoord).rgb, 1.0f);
	gl_FragData[3] = color;
}