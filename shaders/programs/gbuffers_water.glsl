#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"
#include "/lib/fog.glsl"
#include "/lib/color.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;
/*
const int colortex0Format = R11F_G11F_B10F;
*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog = vec4(1.0);
	doFog(color, fog, FOG_OFFSET_DEFAULT);

	color.rgb = sRGBToLinear(color.rgb);
/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(pos,1);
    gl_FogFragCoord = length(pos);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif