#version 120

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

uniform vec4 entityColor;

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 color;
//coord0

//varying vec2 coord0;
//svarying vec2 coord1;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

void main() {
	//vec4 col = texture2D(texture, texcoord) * color;
	//col *= texture2D(lightmap, lmcoord);
	vec3 light = (1.-blindness) * texture2D(lightmap,lmcoord).rgb;
	vec4 col = color * vec4(light,1) * texture2D(texture,texcoord);
	col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);

	//vec3 col = color.rgb;

    //Calculate fog intensity in or out of water.
    vec4 fog;
    if(fogMode == GL_EXP)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR)
        fog.a = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    fog.rgb = gl_Fog.color.rgb;

    //fog = 1.0-fog;

    col.rgb = mix(col.rgb, fog.rgb, fog.a);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = col; //gcolor
	//gl_FragData[1] = fog;
}
