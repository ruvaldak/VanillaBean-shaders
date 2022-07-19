#version 130

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

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
