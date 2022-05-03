#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex8; // normal buffer;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform int frameCounter;

uniform vec3 cameraPosition;

varying vec2 texcoord;
varying vec4 glcolor;

#include "settings.glsl"

const int noiseTextureResolution = 128;

vec2 depth(in vec2 uv) {
	//vec2 depth = texture2D(depthtex0, uv).xy;
	//vec2 depth = ((texture2D(colortex9, uv).xy)-1)*-1;
	vec2 depth = texture2D(colortex9, uv).xy;
	//(depth-1)*-1
	
	/*
	if(texture2D(depthtex0, uv).r = texture2D(colortex9, uv).r) {
		depth.r = 1.0f;
	}
	*/
	//return (depth-1)*-1;
	return depth;
}

vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;
float randomSize = 64.0f; 

float interleavedGradientNoise(vec2 pos) {
    return fract(52.9829189 * fract(0.06711056 * pos.x + (0.00583715 * pos.y)));
}

float interleavedGradientNoise(vec2 pos, int t) {
    return interleavedGradientNoise(pos + 5.588238 * (t & 127));
}

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homogeneousPos = projectionMatrix * vec4(position, 1.0f);
	return homogeneousPos.xyz/homogeneousPos.w;
}

vec3 getPosition(in vec2 uv) {
	vec3 screenPos = vec3(uv, depth(uv));
	vec3 ndcPos = screenPos * 2.0f - 1.0f;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition;
	vec3 feetPlayerPos = worldPos - cameraPosition;
	return viewPos;
}

vec3 getNormal(in vec2 uv) {
	return normalize(texture2D(colortex8, uv).xyz * 2.0f - 1.0f);
}

float doAmbientOcclusion(in vec2 tcoord, in vec2 uv, in vec3 p, in vec3 cnorm) {
	vec3 diff = getPosition(tcoord + uv) - p;
	vec3 v = normalize(diff);
	float d = length(diff)*AO_SCALE;
	return max(0.0f,dot(cnorm,v)-AO_BIAS)*(1.0f/(1.0f+d))*AO_INTENSITY;
}


void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec4 col = glcolor;

	if (clamp(texcoord, 0.0, 1.0) != texcoord) discard;

	float ao = 0.0f;
	vec4 fog = texture2D(colortex3, texcoord);

	#ifdef SSAO
		const float wtf = sqrt(0.5f); //why is this needed? I have no idea

		vec3 p = getPosition(texcoord); 
		vec3 n = getNormal(texcoord); 
		float rad = AO_SAMPLE_RADIUS/p.z; 

		float dither1 = interleavedGradientNoise(gl_FragCoord.xy, frameCounter << 1);
		float dither2 = interleavedGradientNoise(gl_FragCoord.xy, (frameCounter << 1) | 1);

		/*
		for(int i = 0; i < 2; i++) {
			for (int j = 0; j < AO_SAMPLES; ++j) 
			{
				float angle = 2.4 * j + 2*PI*dither2;
				vec2 coord1 = vec2(cos(angle), sin(angle));
				coord1 *= sqrt((j+dither1)/AO_SAMPLES)*rad;
				
				vec2 coord2 = vec2(coord1.x*wtf - coord1.y*wtf, coord1.x*wtf + coord1.y*wtf); 

				for(int i = 0; i < AO_RADIUS_SAMPLES; i++) {
					float mult = 0.0f;
					mult = (i+1.0f)/AO_RADIUS_SAMPLES;
					if(i%2==0)
						ao += doAmbientOcclusion(texcoord,coord1*mult, p, n);// * sqrt(doAmbientOcclusion(texcoord,coord1*mult, p, n)); 
					else
						ao += doAmbientOcclusion(texcoord,coord2*mult, p, n);// * sqrt(doAmbientOcclusion(texcoord,coord2*mult, p, n)); 
				}
			}
		}
		*/
		
		
		for (int j = 0; j < AO_SAMPLES; ++j) 
		{
			float angle = 2.4 * j + 2*PI*dither2;
			vec2 coord1 = vec2(cos(angle), sin(angle))*2;
			coord1 *= sqrt((j+dither1)/AO_SAMPLES)*rad;
			vec2 coord2 = vec2(coord1.x*wtf - coord1.y*wtf, coord1.x*wtf + coord1.y*wtf); 

			for(int i = 0; i < AO_RADIUS_SAMPLES; i++) {
				float mult = 0.0f;
				mult = (i+1.0f)/AO_RADIUS_SAMPLES;
				if(i%2==0)
					ao += doAmbientOcclusion(texcoord,coord1*mult, p, n); 
				else
					ao += doAmbientOcclusion(texcoord,coord1*mult, p, n); 
			}
		}
		
		//ao = ao * sqrt(ao);
		ao/=AO_SAMPLES*4.0f; 

		ao = mix((1.0f - ao) * 0.5f + 0.5f, 1.0, fog.a*2);

		float d = depth(texcoord).r;
    	if(d >= 1.0) ao = 1.0;

    	float f = texture2D(colortex6, texcoord).r*255;
    	if(f == 2. || f == 18. || f == 12.) ao = 1.0;

    	//ao += texture2D(colortex9, texcoord).b;
    #endif

	/* DRAWBUFFERS:5 */
    gl_FragData[0] = vec4(ao, 0.0, 0.0, 0.0);
    
}