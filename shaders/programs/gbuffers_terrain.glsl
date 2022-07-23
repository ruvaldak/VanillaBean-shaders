#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

//uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

in vec3 normal;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in float entity;
in float light;

in vec4 spriteBounds;

#include "/lib/fog.glsl"

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
	#ifdef ANISO_FILTER
		color = textureAF(texture, texcoord, AF_SAMPLES, spriteDimensions, spriteBounds.xy, viewHeight) * glcolor;
	#else
		color = glcolor * texture2D(texture,texcoord);
	#endif
	
    vec2 lm = lmcoord;
    float depth = gl_FragCoord.z;	
	
	//Combine lightmap with blindness.
    vec3 lightmapBlind = texture2D(lightmap,lm).rgb;
	color *= vec4(lightmapBlind,1);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog = vec4(1.0);
    doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03689 */
	gl_FragData[0] = color; //gcolor
	//gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[1] = fog;
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[4] = vec4(depth, 0.0f, light, 1.0f);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Get Entity id.
attribute float mc_Entity;

attribute vec2 mc_midTexCoord;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform sampler2D texture;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out float entity;
out float light;
out vec4 spriteBounds;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);
	// Assign values to varying variables
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  = gl_Color;
	
    //Calculate view space normal.
    normal = gl_NormalMatrix * gl_Normal;

    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1. || mc_Entity == 2. || mc_Entity == 12.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
	//light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;

	//Calculate simple lighting. Thanks to @PepperCode1
	#ifdef NETHER
		//min(x * x * 0.6f + y * y * 0.9f + z * z * 0.8f, 1f);
		light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.9f + normal.z * normal.z * 0.8f, 1.0f);
	#else
		light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);
	#endif
    
    glcolor = vec4(gl_Color.rgb * light, gl_Color.a);

	vec2 spriteRadius = abs(texcoord - mc_midTexCoord.xy);
    vec2 bottomLeft = mc_midTexCoord.xy - spriteRadius;
    vec2 topRight = mc_midTexCoord.xy + spriteRadius;
    spriteBounds = vec4(bottomLeft, topRight);

    entity = mc_Entity;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif