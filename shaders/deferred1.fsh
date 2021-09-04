#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#extension GL_ARB_shader_texture_lod : enable

uniform mat4 gbufferProjectionInverse;

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif
uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float viewWidth;
uniform float viewHeight;

#include "settings.glsl"

varying vec2 texCoord;

void main()
{
    //uv = texCoord
    //iChannel10 = colortex
    //texture = texture2D
    //vec2(0.5 / iChannelResolution[0].xy)).r = vec2(0.5 / vec2(viewWidth, viewHeight))).r
    //vec2(viewWidth, viewHeight) = screen resolution

	vec3 col = texture2D(colortex0, texCoord).rgb;
	float blur;


    blur = 0.0;

    //for(int i = 0; i < AOSamples; i++) {
    blur += texture2D(colortex5, texCoord + vec2(0.0, 1.0) * vec2(0.5 / vec2(viewWidth, viewHeight))).r;
    blur += texture2D(colortex5, texCoord + vec2(1.0, 0.0) * vec2(0.5 / vec2(viewWidth, viewHeight))).r;
    blur += texture2D(colortex5, texCoord - vec2(0.0, 1.0) * vec2(0.5 / vec2(viewWidth, viewHeight))).r;
    blur += texture2D(colortex5, texCoord - vec2(1.0, 0.0) * vec2(0.5 / vec2(viewWidth, viewHeight))).r;
    blur /= 4.0;
    //}

    vec3 blurred = col * blur;

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(blurred, 1.0);
}
