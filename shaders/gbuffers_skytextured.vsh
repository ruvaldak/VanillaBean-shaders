#version 130

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec2 texcoord;
varying vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth, viewHeight;
uniform float frameTimeCounter;

#include "bsl_lib/util/jitter.glsl"

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
