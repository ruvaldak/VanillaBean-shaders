#version 130

//Get Entity id.
attribute float mc_Entity;

attribute vec2 mc_midTexCoord;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying vec3 normal;
varying float entity;
varying float light;
varying vec4 spriteBounds;

#include "/distort.glsl"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    //vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    //Output position and fog to fragment shader.
    //gl_Position = gl_ProjectionMatrix * vec4(viewPos.xyz,1);
    //gl_FogFragCoord = length(viewPos.xyz);
	
	//texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	//lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	//glcolor = gl_Color;

	vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);
	// Assign values to varying variables
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  = gl_Color;
	
    //#ifndef SHADOWS
    //Calculate view space normal.
    normal = gl_NormalMatrix * gl_Normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1. || mc_Entity == 2. || mc_Entity == 12.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,1)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    //light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);
	light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;
    
    glcolor = vec4(gl_Color.rgb * light, gl_Color.a);

	vec2 spriteRadius = abs(texcoord - mc_midTexCoord.xy);
    vec2 bottomLeft = mc_midTexCoord.xy - spriteRadius;
    vec2 topRight = mc_midTexCoord.xy + spriteRadius;
    spriteBounds = vec4(bottomLeft, topRight);

    entity = mc_Entity;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
