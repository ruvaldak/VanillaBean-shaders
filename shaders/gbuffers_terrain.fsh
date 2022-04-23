#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;

uniform sampler2D texture;

void main() {
	vec4 albedo = texture2D(texture, texcoord) * color;

	/* DRAWBUFFERS:012 */
	gl_FragData[0] = albedo;
	gl_FragData[1] = vec4(normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
}