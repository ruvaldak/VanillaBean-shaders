#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/lib/color.glsl"

uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

uniform sampler2D colortex4;

//0-1 amount of blindness.
uniform float blindness;

uniform int frameCounter;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth, viewHeight;

in vec2 texcoord;
in vec4 glcolor;

float interleavedGradientNoise(vec2 pos) {
	return fract(52.9829189 * fract(0.06711056 * pos.x + (0.00583715 * pos.y)));
}

float interleavedGradientNoise(vec2 pos, int t) {
	return interleavedGradientNoise(pos + 5.588238 * (t & 127));
}

void main() {
	vec3 light = vec3(1.-blindness);
    //Sample texture times Visibility.
    vec4 color = glcolor * vec4(light,1) * texture2D(texture,texcoord);

	//float dither = interleavedGradientNoise(gl_FragCoord.xy, frameCounter << 1);
	//color.rgb = mix(color.rgb, vec3(1.0), (dither - 0.5) * 0.23);
	//fog += (dither - 0.5) * 0.23;

	color.rgb = sRGBToLinear(color.rgb);

/* DRAWBUFFERS:049 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = color; //gcolor
	gl_FragData[2] = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth, viewHeight;

out vec2 texcoord;
out vec4 glcolor;

#include "/bsl_lib/util/jitter.glsl"

void main() {
    //Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
	
	glcolor = vec4(gl_Color.rgb, gl_Color.a);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif