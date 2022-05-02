#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#extension GL_ARB_shader_texture_lod : enable

uniform mat4 gbufferProjectionInverse;

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex4; //textured_lit rgb, alpha set to 0
uniform sampler2D colortex5;
uniform sampler2D colortex6; //r = mc_Entity, g = textured_lit alpha
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;

#include "settings.glsl"

//blur radius
//const float radius = 2;

vec2 hash2(vec2 p) {
    return normalize(fract(cos(p*mat2(195,174,286,183))*742.)-.5);
}

void main()
{
	float col = 1.0f;
    #ifdef SSAO
    //Notes for shadertoy stuff:
    //uv = texCoord
    //iChannel10 = colortex
    //texture = texture2D
    //vec2(0.5 / iChannelResolution[0].xy)).r = vec2(0.5 / vec2(viewWidth, viewHeight))).r
    //vec2(viewWidth, viewHeight) = screen resolution
    vec2 texel = 1.0/vec2(viewWidth,viewHeight); //size of a pixel relative to texture size

    //fast simple small bilateral blur by gri573
    int size = AO_BLUR_SIZE;
    float clarity = AO_BLUR_CLARITY;
    col = texture2D(colortex5, texCoord).r;
    float weight = texture2D(depthtex0, texCoord).r;
    //float weight = 0.0;

    #ifdef SSAO_FILTER
    float col1 = 0.0;
    for(int i = -size; i <= size; i++) {
        for(int j = -size; j <= size; j++) {
            float col0 = texture2D(colortex5, texCoord + (vec2(i, j) - 0.5 * vec2(size)) / vec2(viewWidth, viewHeight)).r;
            float weight0 = max(1.0 - clarity * length(col0 - col), 0.00001);
            col1 += weight0 * col0;
            weight += weight0;
        }
    }
    col = col1 / weight;
    #endif

    /*
    vec3 shadowAccum = vec3(0.0f);
		float randomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
		float cosTheta = cos(randomAngle);
		float sinTheta = sin(randomAngle);
		mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
		for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++) {
			for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++) {
				vec2 offset = rotation * vec2(x, y);
				vec3 currentSampleCoordinate = vec3(sampleCoords.xy + offset, sampleCoords.z);
				if ((texture2D(shadowtex0, currentSampleCoordinate.xy).r != texture2D(shadowtex1, currentSampleCoordinate.xy).r))
					shadowAccum += vec3(step(sampleCoords.z - SHADOW_BIAS,texture2D(shadowtex0, currentSampleCoordinate.xy)));
				else
					shadowAccum += vec3(1.0f);
				//sampleCoords += SHADOW_BIAS;
			}
		}
	*/
    //vec3 particle = texture2D(colortex4, texCoord).rgb;


    //1passblur by XorDev
    /*vec3 col = texture2D(colortex0, texCoord).rgb;

    //Initialize blur output color
	float blur = 0.0;
	//Total weight from all samples
	float total = 0.;

	//First sample offset scale
	float scale = AO_BLUR_RADIUS/sqrt(AO_BLUR_SAMPLES);
	//Pseudo-random sample direction
	vec2 point = hash2(texCoord)*scale;
	//Try without noise here:
	//vec2 point = vec2(scale,0);

	//Radius iteration variable
	float rad = 1.;
	//Golden angle rotation matrix
	mat2 ang = mat2(.73736882209777832,-.67549037933349609,.67549037933349609,.73736882209777832);

	//Look through all the samples
	for(float i = 0.;i<AO_BLUR_SAMPLES;i++)
	{
		//Rotate point direction
		point *= ang;
		//Iterate radius variable. Approximately 1+sqrt(i)
		rad += 1./rad;

		//Get sample coordinates
		vec2 coord = texCoord + point*(rad-1.)*texel;
		//Set sample weight
		float weight = 1./rad;
		//Sample texture
		float samp = texture2D(colortex5,coord).r;

		//Add sample and weight totals
		blur += samp * weight;
		total += weight;
	}
	//Divide the blur total by the weight total
	blur /= total;*/
	#endif

	vec4 particle = vec4(texture2D(colortex4, texCoord).rgb, texture2D(colortex6, texCoord).g);
	vec4 depth = texture2D(depthtex0, texCoord);

    /*DRAWBUFFERS:0*/
    //gl_FragData[0] = vec4(col * blur, 1.0);
    gl_FragData[0] = vec4(texture2D(colortex0, texCoord).rgb * col,1.0);
    //gl_FragData[0] = vec4((texture2D(colortex0, texCoord).rgb * col)*texture2D(colortex6, texCoord).g,1.0);
    //gl_FragData[0] = vec4(col, col, col, 1.0f);
    //gl_FragData[0] = vec4(pow(depth.a, 100.), pow(depth.a, 100.), pow(depth.a, 100.), 1.0f);
}


