#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

//#include "/lib/fog.glsl"



uniform int isEyeInWater;

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

void doFog(inout vec4 col, inout vec4 fog) {
    if(fogMode == GL_EXP) //exponential fog
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR) //linear fog
        fog.a = clamp((gl_FogFragCoord-(gl_Fog.start+17.0)) * gl_Fog.scale, 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density); //denser underwater and underlava fog
    
    //fog.rgb = gl_Fog.color.rgb;
    
    vec4 fogpos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
    fogpos = gbufferProjectionInverse * fogpos;
    float upDot = dot(normalize(fogpos.xyz), gbufferModelView[1].xyz);
    fog.rgb = mix(skyColor, fogColor, (0.25 / (max(upDot, 0.0) * max(upDot, 0.0) + 0.25)));

    //Apply the fog.
    col.rgb = mix(col.rgb, fog.rgb, fog.a);
}



void main() {
    vec4 fog;
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
	//Apply fog
	//#include "/lib/fog.glsl"
	doFog(color, fog);

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
}
