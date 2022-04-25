#version 120

varying vec2 texcoord;
varying vec4 color;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;

//uniform sampler2D lightmap;

// color textures:
uniform sampler2D colortex0; // buffer 0 (albedo)
uniform sampler2D colortex1; // buffer 1 (normal vector)
uniform sampler2D colortex2;
uniform sampler2D colortex4; // colortex4.r is 1 if glass, 0 if not

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
uniform vec3 cameraPosition;

uniform float viewWidth, viewHeight;

const bool colortex2Clear = false;

float Ambient = 0.1f;

#include "lib/settings.glsl"

#include "lib/distort.glsl"

const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;

#ifdef SHADOW_FILTER
#endif

vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homogeneousPos = projectionMatrix * vec4(position, 1.0f);
	return homogeneousPos.xyz / homogeneousPos.w;
}

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
	/*vec3 clipSpace = vec3(texcoord, depth) * 2.0f - 1.0f;
	vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0f);
	vec3 view = viewW.xyz / viewW.w;
	vec4 world = gbufferModelViewInverse * vec4(view, 1.0f);*/
	//vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord));
	float entity = (texture2D(colortex4, texcoord).r)*255.0f;
	if(entity != 2.) {
	vec3 screenPos = vec3(texcoord, depth);
	vec3 ndcPos = screenPos * 2.0f - 1.0f;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0f)).xyz;
	vec4 shadowSpace = shadowProjection * vec4(shadowViewPos, 1.0f);
	//vec4 shadowSpace = shadowProjection * shadowModelView * world;
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
				shadowAccum += vec3(step(sampleCoords.z - SHADOW_BIAS, texture2D(shadowtex0, currentSampleCoordinate.xy).r));
				//sampleCoords += SHADOW_BIAS;
			}
		}

		shadowAccum /= totalSamples;
		return shadowAccum;
	#else
		return vec3(step(sampleCoords.z - SHADOW_BIAS, texture2D(shadowtex0, sampleCoords.xy).r));
	#endif
	}
	else
		return vec3(0.0f);
}

void main() {
	vec4 albedo = texture2D(colortex0, texcoord);
	//vec3 normal = texture2D(colortex1, texcoord).rgb;
	float depth = texture2D(depthtex0, texcoord).r;
    if(depth == 1.0f){
        gl_FragData[0] = albedo;
        return;
    }

    //albedo *= color.rgb;


	//float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);
	//Ambient = 1.0f;

	//do lighting. albedo = block color. multiply by modifiers.
	//vec3 diffuse = albedo * (lightmapColor + NdotL + Ambient);
	
	float entity = (texture2D(colortex4, texcoord).r)*255.0f;

	/*
	#ifdef BLUR_GLASS
	if(entity == 2.) {
		float pi = 6.28318530718f;
		float directions = 16.0f;
		float quality = 4.0f;
		float size = 8.0f;

		vec2 radius = size/vec2(viewWidth, viewHeight);

		float randomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
		float cosTheta = cos(randomAngle);
		float sinTheta = sin(randomAngle);
		mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
		for( float d=0.0; d<pi; d+=pi/directions)
    	{
			for(float i=1.0/quality; i<=1.0; i+=1.0/quality)
        	{
				albedo += texture2D(colortex0, texcoord+(rotation * vec2(cos(d),sin(d))*radius*i));
        	}
    	}

    	albedo /= quality * directions - 15.0;
	}
	#endif
	*/
	vec4 diffuse = albedo;

	#ifdef SHADOWS
	if(entity != 2.)
		diffuse *= vec4(GetShadow(depth) * 0.5f + 0.5f, 1.0f);
	else
		diffuse = texture2D(colortex0, texcoord);
	#endif

	float temporalData = 0.0;
    vec3 temporalColor = texture2D(colortex2, texcoord).gba;

    //gl_FragData[0] = col * texture2D(colortex0,coord0);
    
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = diffuse;
	//gl_FragData[1] = vec4(temporalData,temporalColor);
	//gl_FragData[2] = vec4(GetShadow(depth) * 0.5f + 0.5f, 1.0f);
}