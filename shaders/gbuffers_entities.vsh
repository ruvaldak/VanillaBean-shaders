#version 120

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 color;

//varying vec2 coord0;
//varying vec2 coord1;

uniform int frameCounter;
uniform float frameTimeCounter;
attribute float mc_Entity;

uniform float viewWidth, viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	color = gl_Color;

	//Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;

	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    float light = .8-.25*abs(normal.x*.9+normal.z*.3)+normal.y*.2;

    //Output color with lighting to fragment shader.
    color = vec4(gl_Color.rgb * light, gl_Color.a);

	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
