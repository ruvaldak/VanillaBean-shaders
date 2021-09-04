
#ifdef fsh
	#ifdef Global
		//CODE BY BSL CAPT TATSU

		#define SSAO

		uniform sampler2D colortex0;
		varying vec2 texcoord;

		#ifdef SSAO
			uniform int frameCounter;
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
		#endif

		#ifndef SSAO 
			const float ambientOcclusionLevel = 1.0; //Vanilla AO[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
		#endif

		#ifdef SSAO
			float ld(float depth) {
				return (2.0 * near) / (far + near - depth * (far - near));
			}

			//from dither.glsl
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


			//from ssao.glsl
			#define AOAmount 0.45	//[0.40 0.45 0.50 0.55 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.2 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
			#define AOSamples 10 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200]

			vec2 offsetDist(float x, int s){
				float n = fract(x*1.414)*3.1415;
				return vec2(cos(n),sin(n))*x/s;
			}

			float dbao(sampler2D depth, float dither){
				float ao = 0.0;

				int samples = AOSamples;

				float d = texture2D(depth,texcoord.xy).r;
				float hand = float(d < 0.56);
				d = ld(d);

				float sd = 0.0;
				float angle = 0.0;
				float dist = 0.0;
				vec2 scale = 0.6 * vec2(1.0/aspectRatio,1.0) * gbufferProjection[1][1] / (2.74747742 * max(far*d,6.0));

				for (int i = 1; i <= samples; i++) {
					vec2 offset = offsetDist(i + dither, samples) * scale;

					sd = ld(texture2D(depth,texcoord.xy+offset).r);
					float sample = far*(d-sd)*2.0;
					if (hand > 0.5) sample *= 1024.0;
					angle = clamp(0.5-sample,0.0,1.0);
					dist = clamp(0.25*sample-1.0,0.0,1.0);

					sd = ld(texture2D(depth,texcoord.xy-offset).r);
					sample = far*(d-sd)*2.0;
					if (hand > 0.5) sample *= 1024.0;
					angle += clamp(0.5-sample,0.0,1.0);
					dist += clamp(0.25*sample-1.0,0.0,1.0);

					ao += clamp(angle + dist,0.0,1.0);
				}
				ao /= samples;

				return pow(ao,AOAmount);
			}
		#endif

		void main(){
			vec4 color = texture2D(colortex0,texcoord.xy);
			
			#ifdef SSAO
				float z = texture2D(depthtex0,texcoord.xy).r;

				//Dither
				float dither = bayer64(gl_FragCoord.xy);

				color.rgb *= dbao(depthtex0, dither);
			#endif

			/* DRAWBUFFERS:0 */

			gl_FragData[0] = color;
		}
	#endif
#endif