#version 120

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying vec3 bufferNormal;
varying float entity;

#include "/distort.glsl"

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth, viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(viewPos.xyz,1);
    gl_FogFragCoord = length(viewPos.xyz);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
    //#ifndef SHADOWS
    //Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    bufferNormal = normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,1)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    float light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;
    
    glcolor = vec4(gl_Color.rgb * light, gl_Color.a);

    entity = mc_Entity;
    //#else
    //glcolor = vec4(gl_Color.rgb, gl_Color.a);
    //float light = 1.0;
    //#endif

	

	#ifdef SHADOWS
	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	#ifdef EXCLUDE_FOLIAGE
		//when EXCLUDE_FOLIAGE is enabled, act as if foliage is always facing towards the sun.
		//in other words, don't darken the back side of it unless something else is casting a shadow on it.
		if (mc_Entity == 1.) lightDot = 1.0;
	#endif

	if (lightDot > 0.0) { //vertex is facing towards the sun
		vec4 playerPos = gbufferModelViewInverse * viewPos;
		shadowPos = shadowProjection * (shadowModelView * playerPos); //convert to shadow screen space
		float distortFactor = getDistortFactor(shadowPos.xy);
		shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
		shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
		shadowPos.z -= SHADOW_BIAS * (distortFactor * distortFactor) / abs(lightDot); //apply shadow bias
	}
	else { //vertex is facing away from the sun
		lmcoord.y *= SHADOW_BRIGHTNESS; //guaranteed to be in shadows. reduce light level immediately.
		shadowPos = vec4(0.0); //mark that this vertex does not need to check the shadow map.
	}
	shadowPos.w = lightDot;
	#endif
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
