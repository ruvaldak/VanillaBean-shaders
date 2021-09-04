#version 120

//CODE BY BSL CAPT TATSU

#include "settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
varying vec4 color;
varying vec2 texCoord;
uniform int frameCounter;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;

#ifdef SSAO
	uniform int isEyeInWater;
	uniform int worldTime;

	uniform float aspectRatio;
	uniform float blindness;
	uniform float far;
	uniform float frameTimeCounter;
	uniform float near;
	uniform float nightVision;
	uniform float rainStrength;
	uniform float shadowFade;
	uniform float timeAngle;
	uniform float timeBrightness;
	uniform float viewWidth;
	uniform float viewHeight;

	uniform ivec2 eyeBrightnessSmooth;

	uniform vec3 cameraPosition;

	uniform mat4 gbufferProjectionInverse;
	uniform mat4 gbufferModelViewInverse;
	uniform mat4 gbufferProjection;
	uniform mat4 gbufferModelView;


	uniform sampler2D colortex1;
	uniform sampler2D depthtex0;
	uniform sampler2D noisetex;

	vec2 aoOffsets[4] = vec2[4](
        vec2( 1.0,  0.0),
        vec2( 0.0,  1.0),
        vec2(-1.0,  0.0),
        vec2( 0.0, -1.0)
    );
#endif

#ifdef SSAO
	const float ambientOcclusionLevel = 0.0;
#endif

#ifdef SSAO
	float ld(float depth) {
		return (2.0 * near) / (far + near - depth * (far - near));
	}

	float bayer2(vec2 a){
		a = floor(a);
		return fract( dot(a, vec2(.5, a.y * .75)) );
	}

	#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
	#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
	#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
	#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
	#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
	#define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))
	#define bayer256(a) (bayer128(.5*(a))*.25+bayer2(a))

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

	float dbao(sampler2D depth, float dither) {
        float ao = 0.0;

        int samples = AOSamples;

        float dither_base = dither;
        dither = fract(dither + frameTimeCounter * 8.0);
        dither *= 6.283185307;

        float inv_steps = 1.0 / samples;
        float sample_angle_increment = 6.283185307 * inv_steps;
        float current_radius;
        vec2 offset;

        float d = texture2D(depth, texCoord.xy).r;
        float hand_check = d < 0.56 ? 1024.0 : 1.0;
        d = ld(d);

        float sd = 0.0;
        float angle = 0.0;
        float dist = 0.0;
        float far_double = 2.0 * far;
        vec2 scale = vec2(1.0 / aspectRatio, 1.0) * (1.0 / atan(1.0 / gbufferProjection[1][1]) * 0.5 / (d * far));
        //vec2 scale = 0.6 * vec2(1.0/aspectRatio,1.0) * gbufferProjection[1][1] / (2.74747742 * max(far*d,6.0));
        float sample_d;

        vec2 ang = vec2(cos(dither), sin(dither));
        mat2 rotate = mat2(.73736882209777832,-.67549037933349609,.67549037933349609,.73736882209777832);

        for (int i = 1; i <= samples; i++) {
            dither += sample_angle_increment;
            current_radius = (i + dither_base) * inv_steps;
            ang *= rotate;
            offset = ang * scale * current_radius;

            sd = ld(texture2D(depth, texCoord.xy + offset).r);
            sample_d = (d - sd) * far_double * hand_check;
            angle = clamp(0.5 - sample_d, 0.0, 1.0);
            dist = clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

            sd = ld(texture2D(depth, texCoord.xy - offset).r);
            sample_d = (d - sd) * far_double * hand_check;
            angle += clamp(0.5 - sample_d, 0.0, 1.0);
            dist += clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

            ao += clamp(angle + dist, 0.0, 1.0);
        }
        ao /= samples;

        return (ao * AOAmount) + (1.0 - AOAmount);
    }
#endif

void main(){
	vec4 col = color;
    float ao = 0.0;

	#ifdef SSAO
        vec4 fog = texture2D(colortex3, texCoord);
		float z = texture2D(depthtex0,texCoord.xy).r;

		//Dither
		float dither = shifted_eclectic_dither(gl_FragCoord.xy);
		float dither2 = bayer64(gl_FragCoord.xy);

		ao = mix(dbao(depthtex0, dither), 1.0, fog.a);
		/* DRAWBUFFERS:05 */
        gl_FragData[0] = col * texture2D(colortex0,texCoord.xy);
        gl_FragData[1] = vec4(ao, 0.0, 0.0, 0.0);
	#else
        /* DRAWBUFFERS:0 */
        gl_FragData[0] = col * texture2D(colortex0,texCoord.xy);
    #endif
}
