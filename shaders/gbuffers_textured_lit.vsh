#version 120

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
//varying vec3 bufferNormal;
varying float entity;

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
    //bufferNormal = normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    //normal = vec3(0,1,0);
    //normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,1)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    float light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	//glcolor = gl_Color;
	
	glcolor = vec4(gl_Color.rgb, gl_Color.a);

	entity = mc_Entity;
	
	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
