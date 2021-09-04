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
	vec3 light = (1.-blindness) * texture2D(lightmap,lmcoord).rgb;
	vec4 col = color * vec4(light,1) * texture2D(texture,texcoord);
	col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);

	//Apply fog
    #include "/lib/fog.glsl"

/* DRAWBUFFERS:0 */
	gl_FragData[0] = col; //gcolor
	//gl_FragData[1] = fog;
}
