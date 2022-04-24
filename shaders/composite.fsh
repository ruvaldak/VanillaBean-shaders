#version 120

varying vec2 texcoord;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;

//uniform sampler2D lightmap;

// color textures:
uniform sampler2D colortex0; // buffer 0 (albedo)
uniform sampler2D colortex1; // buffer 1 (normal vector, mc_entity attribute (float))

// depth texture
uniform sampler2D depthtex0; // depth buffer 0

uniform sampler2D noisetex;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

float Ambient = 0.1f;

#include "lib/settings.glsl"

#include "lib/distort.glsl"

const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;

#ifdef SHADOW_FILTER
#endif

float Visibility(in sampler2D shadowMap, in vec3 sampleCoords) {
	return step(sampleCoords.z - SHADOW_BIAS, texture2D(shadowMap, sampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 sampleCoords) {
	float shadowVisibility0 = Visibility(shadowtex0, sampleCoords);
	float shadowVisibility1 = Visibility(shadowtex1, sampleCoords);
	vec4 shadowColor0 = texture2D(shadowcolor0, sampleCoords.xy);
	vec3 transmittedColor = shadowColor0.rgb * (1.0f - shadowColor0.a);
	return mix(transmittedColor * shadowVisibility1, vec3(1.0f), shadowVisibility0);
}

vec3 GetShadow(float depth) {
	vec3 clipSpace = vec3(texcoord, depth) * 2.0f - 1.0f;
	vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0f);
	vec3 view = viewW.xyz / viewW.w;
	vec4 world = gbufferModelViewInverse * vec4(view, 1.0f);
	vec4 shadowSpace = shadowProjection * shadowModelView * world;
	shadowSpace.xy = DistortPosition(shadowSpace.xy);
	vec3 sampleCoords = shadowSpace.xyz * 0.5f + 0.5f;
	#if defined SHADOWS && defined SHADOW_FILTER
		vec3 shadowAccum = vec3(0.0f);
		float randomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
		float cosTheta = cos(randomAngle);
		float sinTheta = sin(randomAngle);
		mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
		for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++) {
			for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++) {
				vec2 offset = rotation * vec2(x, y);
				vec3 currentSampleCoordinate = vec3(sampleCoords.xy + offset, sampleCoords.z);
				#ifdef COLORED_SHADOWS
					shadowAccum += TransparentShadow(currentSampleCoordinate);
				#else
					shadowAccum += vec3(step(sampleCoords.z - SHADOW_BIAS, texture2D(shadowtex0, currentSampleCoordinate.xy).r));
				#endif
			}
		}
		shadowAccum /= totalSamples;
		return shadowAccum;
	#else
		#ifdef COLORED_SHADOWS
			return TransparentShadow(sampleCoords);
		#endif
		return vec3(step(sampleCoords.z - SHADOW_BIAS, texture2D(shadowtex0, sampleCoords.xy).r));
	#endif
}

void main() {
	vec3 albedo = texture2D(colortex0, texcoord).rgb;
	vec3 normal = texture2D(colortex1, texcoord).rgb;
	float depth = texture2D(depthtex0, texcoord).r;
    if(depth == 1.0f){
        gl_FragData[0] = vec4(albedo, 1.0f);
        return;
    }

	//float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);
	//Ambient = 1.0f;

	//do lighting. albedo = block color. multiply by modifiers.
	//vec3 diffuse = albedo * (lightmapColor + NdotL + Ambient);
	vec3 diffuse = albedo;
	#ifdef SHADOWS
		diffuse *= ((GetShadow(depth) * 0.5f + 0.5f));
	#endif
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(diffuse, 1.0f);
}