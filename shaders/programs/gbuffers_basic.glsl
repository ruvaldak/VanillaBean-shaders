#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"
#include "/lib/fog.glsl"
#include "/lib/color.glsl"

uniform sampler2D lightmap;
/*
const int colortex0Format = R11F_G11F_B10F;
*/

in vec2 lmcoord;
in vec4 glcolor;

void main() {
    vec4 fog = vec4(1.0);
	vec4 color = glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	//Apply fog
	doFog(color, fog, FOG_OFFSET_DEFAULT);
	color.rgb = sRGBToLinear(color.rgb);
	
	//lolerror

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color * vec4(vec3(1.-blindness),1); //gcolor
	gl_FragData[1] = fog;
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord;
out vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(pos,1);
    gl_FogFragCoord = length(pos);

	//gl_Position = ftransform();
	
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif