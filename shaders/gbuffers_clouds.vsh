#version 120

//Model * view matrix.
uniform mat4 gbufferModelView;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 playerPos;
uniform mat4 gbufferModelViewInverse;
uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();

    vec3 modelPos = gl_Vertex.xyz;
    vec3 viewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0f)).xyz;
    playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0f)).xyz;
	
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(pos,1);
    gl_FogFragCoord = length(pos);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
