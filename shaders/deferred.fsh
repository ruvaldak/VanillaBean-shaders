#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform sampler2D colortex8; // normal buffer;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;

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

const float noiseTextureResolution = 128.0f;

vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;
float randomSize = 64.0f; 

float random() {
    return fract(sin(dot(texture2D(noisetex, texcoord).xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homogeneousPos = projectionMatrix * vec4(position, 1.0f);
	return homogeneousPos.xyz/homogeneousPos.w;
}

vec2 offsetDist(float x, int s){
	float n = fract(x*1.414)*3.1415;
	return vec2(cos(n),sin(n))*x/s;
}

float fmod(float x, float y) {
    return x-y*floor(x/y);
}

float shifted_eclectic_dither(vec2 frag) {
    vec3 p3 = fract(vec3(frag.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    float p4 = fract((p3.x + p3.y) * p3.z) * 0.1;

    // return ((mod(9.0 * frag.x + 16.0 * frag.y, 21.0)) + 0.5) * 0.047619047619047616;
    return fract((0.8 * fmod(frameCounter, 5.0)) + p4 + (((mod(9.0 * frag.x + 16.0 * frag.y, 21.0)) + 0.5) * 0.047619047619047616));
}

vec3 getPosition(in vec2 uv) {
	vec3 screenPos = vec3(uv, texture2D(depthtex0, uv));
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

vec2 getRandom(in vec2 uv) {
	return normalize(texture2D(noisetex, uv * vec2(viewWidth, viewHeight) / noiseTextureResolution).xy * 2.0f - 1.0f);
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

	float ao = 0.0f;
	vec4 fog = texture2D(colortex3, texcoord);

	//aoScale = 0.5f, aoBias = 0.0f, aoIntensity = 1.0f, aoSampleRadius = 0.15f;

	float dither = shifted_eclectic_dither(gl_FragCoord.xy);
	dither = fract(frameTimeCounter * 4.0 + dither);

	#ifdef SSAO
		vec3 p = getPosition(texcoord); 
		vec3 n = getNormal(texcoord); 
		vec2 rand = getRandom(texcoord); 
		float rad = AO_SAMPLE_RADIUS/p.z; 

		/*const int multiple = 4;
		const int count = 2;
		const int iterations = int(pow(multiple,count)); */
		
		/*vec2 vec[iterations];

		for(int i = 0; i < iterations; i++) {
			float val = (i/multiple)+1;
			val*=multiple;
			val = val/iterations;

			if(i%2==0) {
				vec[i].x = val;
				vec[++i].y = val;
				vec[++i].x = 0-val;
				vec[++i].y = 0-val;
			}
		}*/
		/*vec[0] = vec2(1.0f,0.0f);
		vec[1] = vec2(-1.0f,0.0f);
		vec[2] = vec2(0.0f,1.0f);
		vec[3] = vec2(0.0f,-1.0f);*/

		
		const float wtf = sqrt(0.5f);

		float randomNum1 = texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).x;
		float randomNum2 = texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).y;
		//float randomNum1 = texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).x;
		//float randomNum1 = texture2D(noisetex, texcoord).r;
		//float randomNum1 = 0.5;
		//float randomNum1 = random();
		//float randomNum1 = fract(sin(dot(texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).xy, vec2(12.9898, 78.233))) * 43758.5453);

		for (int j = 0; j < AO_SAMPLES; ++j) 
		{
			//randomNum1 = texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).x;
			float angle = 2.4 * j + 2*PI*randomNum2;
			//float angle = 2.4 * j;
			vec2 coord1 = vec2(cos(angle), sin(angle));
			//randomNum1 = random(coord1);
			coord1 *= sqrt((j+randomNum1)/AO_SAMPLES)*rad;
			//coord1 = coord1 * rad;
			//vec2 coord1 = reflect(vec[j],rand)*rad; 
			
			vec2 coord2 = vec2(coord1.x*wtf - coord1.y*wtf, coord1.x*wtf + coord1.y*wtf); 

			//ao += doAmbientOcclusion(texcoord,coord1*random(texcoord), p, n);
			//ao += doAmbientOcclusion(texcoord,coord2*random(texcoord), p, n);
			for(int i = 0; i < AO_RADIUS_SAMPLES; i++) {
				float mult = 0.0f;
				mult = (i+1.0f)/AO_RADIUS_SAMPLES;
				if(i%2==0)
					ao += doAmbientOcclusion(texcoord,coord1*mult, p, n); 
				else
					ao += doAmbientOcclusion(texcoord,coord2*mult, p, n); 
			}
			/*ao += doAmbientOcclusion(texcoord,coord1*0.25f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord2*0.5f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord1*0.75f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord2, p, n); */
		}

		for (int j = 0; j < AO_SAMPLES; ++j) 
		{
			//randomNum1 = texture2D(noisetex, gl_FragCoord.xy / noiseTextureResolution).x;
			float angle = 2.4 * j + 2*PI*randomNum2;
			//float angle = 2.4 * j;
			vec2 coord1 = vec2(cos(angle), sin(angle));
			//randomNum1 = random(coord1);
			coord1 *= sqrt((j+randomNum1)/AO_SAMPLES)*rad;
			//coord1 = coord1 * rad;
			//vec2 coord1 = reflect(vec[j],rand)*rad; 
			vec2 coord2 = vec2(coord1.x*wtf - coord1.y*wtf, coord1.x*wtf + coord1.y*wtf); 

			//ao += doAmbientOcclusion(texcoord,coord1*random(texcoord), p, n);
			//ao += doAmbientOcclusion(texcoord,coord2*random(texcoord), p, n);
			for(int i = 0; i < AO_RADIUS_SAMPLES; i++) {
				float mult = 0.0f;
				mult = (i+1.0f)/AO_RADIUS_SAMPLES;
				if(i%2==0)
					ao += doAmbientOcclusion(texcoord,coord1*mult, p, n); 
				else
					ao += doAmbientOcclusion(texcoord,coord2*mult, p, n); 
			}
			/*ao += doAmbientOcclusion(texcoord,coord1*0.25f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord2*0.5f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord1*0.75f, p, n); 
			ao += doAmbientOcclusion(texcoord,coord2, p, n); */
		}

		ao/=AO_SAMPLES*4.0f; 

		//ao = (1.0f - ao) * 0.5f + 0.5f;

		ao = mix((1.0f - ao) * 0.5f + 0.5f, 1.0, fog.a*2);

		float d = texture2D(depthtex0, texcoord).r;
    	if(d >= 1.0) ao = 1.0;
    #endif
	//color *= ao;

	/* DRAWBUFFERS:5 */
    //gl_FragData[0] = col * texture2D(colortex0,texcoord.xy);
    gl_FragData[0] = vec4(ao, 0.0, 0.0, 0.0);
    
}