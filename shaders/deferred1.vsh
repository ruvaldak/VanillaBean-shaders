#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.


varying vec2 texCoord;

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main()
{
    gl_Position = ftransform();

    texCoord = gl_MultiTexCoord0.xy;

    //gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
