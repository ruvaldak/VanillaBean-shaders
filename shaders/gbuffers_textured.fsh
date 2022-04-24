#version 120

uniform sampler2D lightmap;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;
varying float blockId;

uniform sampler2D texture;

void main() {
	vec4 albedo = texture2D(texture, texcoord) * color;
	vec4 light = vec4(texture2D(lightmap,lmcoord).rgb, 1.0f);
	albedo *= light;

	/* DRAWBUFFERS:014 */
	gl_FragData[0] = albedo;
	gl_FragData[1] = vec4(normal, 1.0f);
	gl_FragData[2] = vec4(blockId, 0.0f, 0.0f, 1.0f);
	//gl_FragData[3] = color;
}