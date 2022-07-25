#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"
#include "/lib/color.glsl"
#include "/lib/fog.glsl"

uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
const int colortex0Format = R11F_G11F_B10F;
*/

//uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
//RGB/intensity for hurt entities and flashing creepers.
uniform vec4 entityColor;

varying vec3 bufferNormal;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float entity;

void main() {	
    vec4 color = glcolor * texture2D(texture,texcoord);
    vec2 lm = lmcoord;
	
	//Combine lightmap with blindness.
    vec3 light = texture2D(lightmap,lm).rgb;
	color *= vec4(light,1);
    color.rgb = mix(color.rgb,entityColor.rgb,entityColor.a);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog = vec4(1.0);
	doFog(color, fog, FOG_OFFSET_DEFAULT);
	color.rgb = sRGBToLinear(color.rgb);


/* DRAWBUFFERS:03689 */
	gl_FragData[0] = color; //gcolor
	//gl_FragData[2] = vec4(lmcoord, 0.0f, 1.0f);
	gl_FragData[1] = fog;
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(bufferNormal * 0.5f + 0.5f, 1.0f);
	gl_FragData[4] = vec4(gl_FragCoord.z, 0.0f, 0.0f, 1.0f);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Get Entity id.
attribute float mc_Entity;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 bufferNormal;
varying vec4 glcolor;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * viewPos;
    gl_FogFragCoord = length(vec3(viewPos.xyz));
    
    //Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    bufferNormal = normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    normal = (mc_Entity==1. || mc_Entity == 2. || mc_Entity == 12.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
	//Calculate simple lighting. Thanks to @PepperCode1
    float light = 0.0;
	#ifdef NETHER
		//min(x * x * 0.6f + y * y * 0.9f + z * z * 0.8f, 1f);
		light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.9f + normal.z * normal.z * 0.8f, 1.0f);
	#else
		light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);
	#endif
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	//glcolor = gl_Color;
	
	glcolor = vec4(gl_Color.rgb * light, gl_Color.a);
		
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif