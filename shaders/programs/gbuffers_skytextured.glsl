#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

uniform sampler2D colortex4;

//0-1 amount of blindness.
uniform float blindness;
//0 = default, 1 = water, 2 = lava.
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

in vec2 texcoord;
in vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	//Apply fog
	//#include "/lib/fog.glsl"

/* DRAWBUFFERS:049 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = color; //gcolor
	//gl_FragData[1] = fog;
	gl_FragData[2] = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

out vec2 texcoord;
out vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth, viewHeight;
uniform float frameTimeCounter;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //texcoord = gl_Position * 0.5 + 0.5;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);

	//gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif