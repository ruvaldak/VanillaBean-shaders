#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//uniform mat4 gbufferProjectionInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D depthtex0;
uniform float far;

#include "settings.glsl"

//varying vec2 texCoord;

varying vec4 color;
varying vec2 coord0;

const bool colortex2Clear = false;

void main()
{
    vec4 col = color;
    float temporalData = 0.0;
    vec3 temporalColor = texture2D(colortex2, coord0).gba;

    /*DRAWBUFFERS:12*/
    gl_FragData[0] = col * texture2D(colortex0,coord0);
    gl_FragData[1] = vec4(temporalData,temporalColor);
}
