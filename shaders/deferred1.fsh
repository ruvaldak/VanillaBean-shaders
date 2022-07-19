#version 130

uniform mat4 gbufferProjectionInverse;

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex4; //textured_lit rgb, alpha set to 0
uniform sampler2D colortex5;
uniform sampler2D colortex6; //r = mc_Entity, g = textured_lit alpha
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;

#include "settings.glsl"

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
    float weight = AO_BLUR_WEIGHT;

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

	#endif

	vec4 particle = vec4(texture2D(colortex4, texCoord).rgb, texture2D(colortex6, texCoord).g);
	vec4 depth = texture2D(depthtex0, texCoord);

	vec3 render;
	#ifdef ONLY_SSAO
		render = vec3(col, col, col);
	#else
		render = texture2D(colortex0, texCoord).rgb * col;
	#endif

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(render, 1.0f);
    //gl_FragData[0] = 1-texture2D(colortex4, texCoord);
}


