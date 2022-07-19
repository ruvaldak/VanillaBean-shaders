#version 130

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float entity;
varying vec3 bufferNormal;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

//#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(pos,1);
    gl_FogFragCoord = length(pos);
    
    //Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    bufferNormal = normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1. || mc_Entity == 2. || mc_Entity == 12.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,1)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    float light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	glcolor = vec4(gl_Color.rgb * light, gl_Color.a);

	entity = mc_Entity;
	
	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
