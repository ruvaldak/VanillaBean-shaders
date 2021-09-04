#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//Diffuse (color) texture.
uniform sampler2D texture;
//Lighting from day/night + shadows + light sources.
uniform sampler2D lightmap;

//RGB/intensity for hurt entities and flashing creepers.
uniform vec4 entityColor;
//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;
//Diffuse and lightmap texture coordinates.
varying vec2 coord0;
varying vec2 coord1;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

void main()
{
    //Combine lightmap with blindness.
    vec3 light = (1.-blindness) * texture2D(lightmap,coord1).rgb;
    //Sample texture times lighting.
    vec4 col = color * vec4(light,1) * texture2D(texture,coord0);
    //Apply entity flashes.
    col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);

    //Calculate fog intensity in or out of water.
    vec4 fog;
    //fog = vec4(1);
    //fog.a = gl_Fog.scale;
    if(fogMode == GL_EXP)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR)
        fog.a = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);

    //float fog = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);
    fog.rgb = gl_Fog.color.rgb;

    //fog = 1.0-fog;

    //Apply the fog.
	col.rgb = mix(col.rgb, fog.rgb, fog.a);
    //Output the result.
    /*DRAWBUFFERS:03*/
    gl_FragData[0] = col;
    gl_FragData[1] = fog;
}
