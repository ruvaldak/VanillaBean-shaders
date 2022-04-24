#version 120

uniform mat4 gbufferProjectionInverse;

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;

#include "lib/settings.glsl"

vec2 hash2(vec2 p) {
    return normalize(fract(cos(p*mat2(195,174,286,183))*742.)-.5);
}

void main()
{
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

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(texture2D(colortex0, texCoord).rgb * col,1.0);
    #endif
}

