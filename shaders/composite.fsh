#version 120

varying vec2 texcoord;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;

//uniform sampler2D lightmap;

// color textures:
uniform sampler2D colortex0; // buffer 0 (albedo)
uniform sampler2D colortex1; // buffer 1 (normal vector, mc_entity attribute (float))
uniform sampler2D colortex2; // buffer 2 (lightmap)
uniform sampler2D colortex3; // buffer 3 (exact copy of gl_Color)

// depth texture
uniform sampler2D depthtex0; // depth buffer 0

uniform sampler2D shadowtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const float sunPathRotation = 0.0f;

float Ambient = 0.1f;

#include "settings.glsl"

float GetShadow(float depth) {
	vec3 clipSpace = vec3(texcoord, depth) * 2.0f - 1.0f;
	vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0f);
	vec3 view = viewW.xyz / viewW.w;
	vec4 world = gbufferModelViewInverse * vec4(view, 1.0f);
	vec4 shadowSpace = shadowProjection * shadowModelView * world;
	vec3 sampleCoords = shadowSpace.xyz * 0.5f + 0.5f;
	return step(sampleCoords.z - 0.001f, texture2D(shadowtex0, sampleCoords.xy).r);
}

void main() {
	vec3 color = texture2D(colortex3, texcoord).rgb;
	vec3 albedo = texture2D(colortex0, texcoord).rgb;
	vec3 lightmap = texture2D(colortex2, texcoord).rgb;
	vec3 normal = texture2D(colortex1, texcoord).rgb;

	albedo *= color;
	albedo *= lightmap;

	float depth = texture2D(depthtex0, texcoord).r;
    if(depth == 1.0f){
        gl_FragData[0] = vec4(albedo, 1.0f);
        return;
    }

	float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);
	Ambient = 1.0f;

	//do lighting. albedo = block color. multiply by modifiers.
	//vec3 diffuse = albedo * (lightmapColor + NdotL + Ambient);
	vec3 diffuse = albedo * ((GetShadow(depth) * 0.5f + 0.5f));

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(diffuse, 1.0f);
}