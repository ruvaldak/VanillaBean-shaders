#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//Diffuse (color) texture.
uniform sampler2D texture;

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;
//Diffuse texture coordinates.
varying vec2 coord0;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

void main()
{
    //Visibility amount.
    vec3 light = vec3(1.-blindness);
    //Sample texture times Visibility.
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);

	//Apply fog
	#include "/lib/fog.glsl"
    //Output the result.
    /*DRAWBUFFERS:03*/
    gl_FragData[0] = col;
    gl_FragData[1] = fog;
}
