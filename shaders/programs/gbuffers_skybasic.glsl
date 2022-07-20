//Thanks to Emin for the vast majority of this code

#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

//Extensions//

//Varyings//
in float vanillaStars;

in vec3 upVec;

in vec4 glColor;

//Uniforms//
uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;
uniform vec3 fogColor;
uniform vec3 skyColor;

uniform mat4 gbufferProjectionInverse;

//Attributes//

//Optifine Constants//

//Common Variables//

//Common Functions//
float Bayer2  (vec2 c) { c = 0.5 * floor(c); return fract(1.5 * fract(c.y) + c.x); }
float Bayer4  (vec2 c) { return 0.25 * Bayer2(0.5 * c) + Bayer2(c); }

//Includes//

//Program//
void main() {
	vec4 color = vec4(glColor.rgb, 1.0);
	
	if (vanillaStars < 0.5) {
		vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
		vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
		viewPos /= viewPos.w;
		vec3 nViewPos = normalize(viewPos.xyz);
		float NdotU = dot(nViewPos, upVec);

		if (isEyeInWater == 0) {
			float NdotUM = 1.0 - NdotU;
			NdotUM *= NdotUM;
			NdotUM *= NdotUM;
			NdotUM = min(NdotUM * NdotUM * 1.7, 1.0);

			color.rgb = mix(skyColor, fogColor, NdotUM);
			
			if (glColor.a < 0.999) color.rgb = mix(color.rgb, glColor.rgb, glColor.a);
		} else if (isEyeInWater == 1) {
			float NdotUM = 1.0 - clamp((NdotU - 0.25) / 0.75, 0.0, 1.0);
			color.rgb = mix(skyColor, fogColor, NdotUM);
		} else if (isEyeInWater >= 2) {
			color.rgb = fogColor;
		}

		float dither = Bayer4(gl_FragCoord.xy);
		color.rgb += (dither - 0.5) / 128.0;
	} else color.a = glColor.a;

/* DRAWBUFFERS:079 */
	gl_FragData[0] = color;
	gl_FragData[1] = color;
	gl_FragData[2] = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Varyings//
out float vanillaStars;

out vec3 upVec;

out vec4 glColor;

//Uniforms//
uniform mat4 gbufferModelView;
uniform float viewWidth;
uniform float viewHeight;

//Attributes//

//Optifine Constants//

//Common Variables//

//Common Functions//

//Includes//
#include "/bsl_lib/util/jitter.glsl"

//Program//
void main() {
	gl_Position = ftransform();

	glColor = gl_Color;
	
	upVec = normalize(gbufferModelView[1].xyz);
	
	//Vanilla Star Dedection by Builderb0y
	vanillaStars = float(glColor.r == glColor.g && glColor.g == glColor.b && glColor.r > 0.0);

	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif