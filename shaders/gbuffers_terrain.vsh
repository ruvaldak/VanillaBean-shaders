#version 120

attribute float mc_Entity;

uniform mat4 gbufferModelViewInverse;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;

varying float isFlat;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal = gl_NormalMatrix * gl_Normal;

    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;

    //Calculate simple lighting. Credit to XorDev.
    float light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;
	
	color = vec4(gl_Color.rgb * light, gl_Color.a);

	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}