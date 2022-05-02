#version 120

#include "settings.glsl"

uniform vec3 sunPosition;

uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;

//uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec3 bufferNormal;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float entity;

//fix artifacts when colored shadows are enabled
const bool shadowcolor0Nearest = true;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

//0-1 amount of blindness.
uniform float blindness;

#include "/lib/fog.glsl"

/*
you compute the average of the shadows of neighbouring pixels

this means,
1) Doing a nested loop that goes from 0 to shadow_samples_count on both axis (X and Y)
2) Using vec2(x, y) * (1.0 / vec2(viewWidth, viewHeight)) as an offset to your texture coordinates 

Why multiplying by (1.0 / vec2(viewWidth, viewHeight)) ?

This is the pixel size, you want your offset to be scaled to the pixels on your window.
viewWidth and viewHeight are Optifine uniforms. You should keep pixelSize somewhere in your
files, cause you'll use it pretty often.

3) Sampling your shadows at shadowCoordinates + offset
4) [OUTSIDE OF THE LOOP] Divide the total sum of your neighbouring shadows by the total amount of samples


by the way, don't multiply by the pixel size, divide by the shadowmap resolution instead
*/


#define SHADOW_SAMPLES_COUNT 2

/*
float shadowSamples = texture2D(shadowtex0, shadowPos.xy).r;
int samples = 1;

float shadowSamples1 = 0.0;
for (int x = 0; x < SHADOW_SAMPLES_COUNT; x++) {
	for (int y = 0; y < SHADOW_SAMPLES_COUNT; y++) {
		float shadow = texture2D(shadowtex0, shadowPos.xy + (vec2(x, y) / shadowMapResolution)).r;
		shadowSamples1 += shadow;

		samples++
	}
}

shadowSamples = shadowSamples1 / float(samples);
*/

/*
int size = AO_BLUR_SIZE;
    float clarity = AO_BLUR_CLARITY;
    float col = texture2D(colortex5, texCoord).r;
    float weight = AO_BLUR_WEIGHT;

    float col1 = 0.0;
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            float col0 = texture2D(colortex5, texCoord + (vec2(i, j) - 0.5 * vec2(size)) / vec2(viewWidth, viewHeight)).r;
            float weight0 = max(1.0 - clarity * length(col0 - col), 0.00001);
            col1 += weight0 * col0;
            weight += weight0;
        }
    }
    col = col1 / weight;
*/

/*float GetShadow(void) {
	vec3 ClipSpace = vec3(texcoord, texture2D(depthtex0, texcoord).r) * 2.0f - 1.0f;
	vec4 ViewW = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
	vec3 View = ViewW.xyz / ViewW.w;
	vec4 World = gbufferModelViewInverse * vec4(View, 1.0f);
	vec4 ShadowSpace = shadowProjection * shadowModelView * World;
	vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;
	return step(SampleCoords.z, texture2D(shadowtex0, SampleCoords.xy).r);
}*/

/*
const float Ambient = 0.025f;

float AdjustLightmapTorch(in float torch) {
    const float K = 2.0f;
    const float P = 5.06f;
    return K * pow(torch, P);
}

float AdjustLightmapSky(in float sky){
    float sky_2 = sky * sky;
    return sky_2 * sky_2;
}

vec2 AdjustLightmap(in vec2 Lightmap){
    vec2 NewLightMap;
    NewLightMap.x = AdjustLightmapTorch(Lightmap.x);
    NewLightMap.y = AdjustLightmapSky(Lightmap.y);
    return NewLightMap;
}

vec3 GetLightmapColor(in vec2 Lightmap){
    // First adjust the lightmap
    Lightmap = AdjustLightmap(Lightmap);
    // Color of the torch and sky. The sky color changes depending on time of day but I will ignore that for simplicity
    const vec3 TorchColor = vec3(1.0f, 0.25f, 0.08f);
    const vec3 SkyColor = vec3(0.05f, 0.15f, 0.3f);
    // Multiply each part of the light map with it's color
    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 SkyLighting = Lightmap.y * SkyColor;
    // Add the lighting togther to get the total contribution of the lightmap the final color.
    vec3 LightmapLighting = TorchLighting + SkyLighting;
    // Return the value
    return LightmapLighting;
}*/

void main() {
	//vec4 color = texture2D(texture, texcoord) * glcolor;
	//color *= texture2D(lightmap, lmcoord);
	
    vec4 color = glcolor * texture2D(texture,texcoord);
    vec2 lm = lmcoord;

    #ifdef SHADOWS
    float shadowSamples = texture2D(shadowtex0, shadowPos.xy).r;

    float shadowSamples1 = 0.0;
	int samples = 1;

	for (int x = 0; x < SHADOW_SAMPLES_COUNT; x++) {
		for (int y = 0; y < SHADOW_SAMPLES_COUNT; y++) {
			float shadow = texture2D(shadowtex0, shadowPos.xy + (vec2(x, y) / shadowMapResolution)).r;
			shadowSamples1 += shadow;

			samples++;
		}
	}

	shadowSamples = shadowSamples1 / float(samples);
	//lm.y *= shadowSamples;

	
	if (shadowPos.w > 0.0) {
		//surface is facing towards shadowLightPosition

		#if COLORED_SHADOWS == 0
			//for normal shadows, only consider the closest thing to the sun,
			//regardless of whether or not it's opaque.
			if (texture2D(shadowtex0, shadowPos.xy).r < shadowPos.z) {
		#else
			//for invisible and colored shadows, first check the closest OPAQUE thing to the sun.
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
		#endif
			//surface is in shadows. reduce light level.
			lm.y *= SHADOW_BRIGHTNESS;
			//lm.y += shadowSamples;
		}
		else {
			//surface is in direct sunlight. increase light level.
			lm.y = mix(31.0 / 32.0 * (1.0), 31.0 / 32.0, sqrt(shadowPos.w));
			//lm.y *= ((shadowSamples * 0.5 + 0.5));
			#if COLORED_SHADOWS == 1
				//when colored shadows are enabled and there's nothing OPAQUE between us and the sun,
				//perform a 2nd check to see if there's anything translucent between us and the sun.
				if (texture2D(shadowtex0, shadowPos.xy).r < shadowPos.z) {
					//surface has translucent object between it and the sun. modify its color.
					//if the block light is high, modify the color less.
					vec4 shadowLightColor = texture2D(shadowcolor0, shadowPos.xy);
					//make colors more intense when the shadow light color is more opaque.
					shadowLightColor.rgb = mix(vec3(1.0), shadowLightColor.rgb, shadowLightColor.a);
					//also make colors less intense when the block light level is high.
					shadowLightColor.rgb = mix(shadowLightColor.rgb, vec3(1.0), lm.x);
					//apply the color.
					color.rgb *= shadowLightColor.rgb;
				}
			#endif
		}
	}
	#endif
	

	//Combine lightmap with blindness.
    vec3 light = (1.-blindness) * texture2D(lightmap,lm).rgb;
	color *= vec4(light,1);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog;
    doFog(color, fog);
	

	/*
    vec3 Albedo = (texture2D(texture, texcoord) * glcolor).rgb;
    //vec3 Albedo = pow((texture2D(texture, texcoord) * glcolor).rgb, vec3(2.2f));
    float Depth = texture2D(depthtex0, texcoord).r;
    // Get the normal

    vec3 Normal = normalize(vec4(normal * 0.5f + 0.5f, 1.0f).rgb * 2.0f - 1.0f);
    // Get the lightmap
    vec2 Lightmap = vec4(lmcoord, 0.0f, 1.0f).rg;
    vec3 LightmapColor = GetLightmapColor(Lightmap);
    // Compute cos theta between the normal and sun directions
    float NdotL = max(dot(Normal, normalize(sunPosition)), 0.0f);
    // Do the lighting calculations
    vec3 Diffuse = Albedo * (LightmapColor + NdotL + Ambient);*/

/* DRAWBUFFERS:0368 */
	gl_FragData[0] = color; //gcolor
	//gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[1] = fog;
	//gl_FragData[2] = vec4(shadowSamples);
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(bufferNormal * 0.5f + 0.5f, 1.0f);
}
