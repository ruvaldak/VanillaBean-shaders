#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);
	
	vec4 fog = vec4(1.0);
	doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * viewPos;
    gl_FogFragCoord = length(vec3(viewPos.xyz));
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	//glcolor = vec4(gl_Color.rgb * light, gl_Color.a);
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif