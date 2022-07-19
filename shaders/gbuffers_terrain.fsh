#version 120

#include "settings.glsl"

uniform vec3 sunPosition;

uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

//uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec3 normal;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float entity;
varying float light;

varying vec4 spriteBounds;

//varying vec2 texCoords;

//fix artifacts when colored shadows are enabled
const bool shadowcolor0Nearest = true;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

//0-1 amount of blindness.
uniform float blindness;

#include "/lib/fog.glsl"

#define SHADOW_SAMPLES_COUNT 2



float manualDeterminant(mat2 matrix) {
    return matrix[0].x * matrix[1].y - matrix[0].y * matrix[1].x;
}

mat2 inverse(mat2 m)
{
    mat2 adj;
    adj[0][0] = m[1][1];
    adj[0][1] = -m[0][1];
    adj[1][0] = -m[1][0];
    adj[1][1] = m[0][0];
    return adj / manualDeterminant(m);
}

vec4 textureAF(sampler2D sampler, vec2 uv, float samples, vec2 spriteDimensions, vec2 spriteCorner, float viewportHeight) {
	mat2 J = inverse(mat2(dFdx(uv), dFdy(uv)));     // dFdxy: pixel footprint in texture space
	J = transpose(J)*J;                             // quadratic form
	float d = manualDeterminant(J), t = J[0][0]+J[1][1],  // find ellipse: eigenvalues, max eigenvector
		  D = sqrt(abs(t*t-4.0*d)),                 // abs() fix a bug: in weird view angles 0 can be slightly negative
		  V = (t-D)/2.0, v = (t+D)/2.0,                // eigenvalues
		  M = 1.0/sqrt(V), m = 1./sqrt(v);             // = 1./radii^2
	vec2 A = M * normalize(vec2(-J[0][1], J[0][0]-V)); // max eigenvector = main axis

	float lod;
	if (M/m > 16.0) {
		lod = log2(M / 16.0 * viewportHeight);
	} else {
		lod = log2(m * viewportHeight);
	}

	float samplesDiv2 = samples / 2.0;
	vec2 ADivSamples = A / samples;

	vec3 finalRGB = vec3(0);
	for (float i = -samplesDiv2 + 0.5; i < samplesDiv2; i++) { // sample along main axis at LOD min-radius
		vec2 sampleUV = uv + ADivSamples * i;
		sampleUV = mod(sampleUV - spriteCorner, spriteDimensions) + spriteCorner; // wrap sample UV to fit inside sprite
		finalRGB += texture2DLod(sampler, sampleUV, lod).rgb;
	}
	finalRGB = finalRGB / samples;
	return vec4(finalRGB, texture2DLod(sampler, uv, lod).a); // preserve original alpha to prevent artifacts
}

void main() {	
	vec2 spriteDimensions = vec2(spriteBounds.z - spriteBounds.x, spriteBounds.w - spriteBounds.y);
	vec4 color;
	/*
	if(entity==1.) {
		color = glcolor * texture2D(texture,texcoord);
	} else {
		color = textureAF(texture, texcoord, AF_SAMPLES, spriteDimensions, spriteBounds.xy, viewHeight) * glcolor;
	}
	*/
    //
	#ifdef ANISO_FILTER
		color = textureAF(texture, texcoord, AF_SAMPLES, spriteDimensions, spriteBounds.xy, viewHeight) * glcolor;
	#else
		color = glcolor * texture2D(texture,texcoord);
	#endif
	
    vec2 lm = lmcoord;
    float depth = gl_FragCoord.z;	
	
	//Combine lightmap with blindness.
    vec3 lightmapBlind = (1.-blindness) * texture2D(lightmap,lm).rgb;
	color *= vec4(lightmapBlind,1);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog;
    doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03689 */
	gl_FragData[0] = color; //gcolor
	//gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[1] = fog;
	//gl_FragData[2] = vec4(shadowSamples);
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[4] = vec4(depth, 0.0f, light, 1.0f);
}
