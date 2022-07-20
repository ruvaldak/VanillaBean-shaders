#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform sampler2D colortex9;
/*
const int colortex9Format = R32F;
*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 bufferNormal;
varying vec4 glcolor;
varying float entity;

//RGB/intensity for hurt entities and flashing creepers.
uniform vec4 entityColor;
//0-1 amount of blindness.
uniform float blindness;

#include "/lib/fog.glsl"

void main() {
	//vec4 color = texture2D(texture, texcoord) * glcolor;
	//color *= texture2D(lightmap, lmcoord);
	
	//Combine lightmap with blindness.
    //vec3 lightmapBlind = (1.-blindness) * texture2D(lightmap,lmcoord).rgb;
	//color *= vec4(lightmapBlind,1);
    //Sample texture times lighting.
    //vec4 color = glcolor * texture2D(texture,texcoord);
    //Apply entity flashes.
    //color.rgb = mix(color.rgb,entityColor.rgb,entityColor.a);

	vec3 light = (1.-blindness) * texture2D(lightmap, lmcoord).rgb;
	vec4 color = glcolor * vec4(light, 1) * texture2D(texture, texcoord);

	//Apply fog
    //#include "/lib/fog.glsl"
    vec4 fog = vec4(1.0);
    doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03689 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
	gl_FragData[2] = vec4(entity/255, 0.0f,vec2(1.0f));
	gl_FragData[3] = vec4(bufferNormal, 1.0f);
	gl_FragData[4] = vec4(1.0f, 0.0f, 0.0f, 1.0f);
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
varying vec4 glcolor;
varying float entity;
varying vec3 bufferNormal;

uniform int frameCounter;
uniform float frameTimeCounter;

uniform float viewWidth;
uniform float viewHeight;

//#include "/bsl_lib/util/jitter.glsl"

void main() {
	//gl_Position = ftransform();
	
	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(pos,1);
    gl_FogFragCoord = length(pos);
    
    //Calculate view space normal.
    vec3 normal = vec3(0,1,0);
    bufferNormal = normal;
    //bufferNormal = mat3(gbufferModelViewInverse) * normal;
    //Use flat for flat "blocks" or world space normal for solid blocks.
    //normal = (mc_Entity==1. || mc_Entity == 2. || mc_Entity == 12.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,1)).xyz;
    //bufferNormal = normal;

    //Calculate simple lighting. Note: This as close as I (XorDev) could get, but it's not perfect!
    float light = .8-.25*abs(normal.x*.8+normal.z*.0)+normal.y*.2;
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	
	glcolor = vec4(gl_Color.rgb * light, gl_Color.a);

	entity = mc_Entity;
	
	//gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif