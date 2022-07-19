#version 150 compatibility

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

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
