#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

#include "/settings.glsl"

uniform sampler2D texture;

in vec2 texcoord;
in vec4 glcolor;

#include "/lib/fog.glsl"

void main() {
    vec4 fog = vec4(1.0);
	vec4 color = texture2D(texture, texcoord) * glcolor;

	doFog(color, fog, FOG_OFFSET_DEFAULT);

/* DRAWBUFFERS:03 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = fog;
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

//Model * view matrix.
uniform mat4 gbufferModelView;

out vec2 texcoord;
out vec4 glcolor;
out vec3 playerPos;
uniform mat4 gbufferModelViewInverse;
uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();

    vec3 modelPos = gl_Vertex.xyz;
    vec3 viewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0f)).xyz;
    playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0f)).xyz;

	//Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * vec4(viewPos,1);
    //gl_FogFragCoord = length(pos);
    gl_FogFragCoord = max(length(playerPos.xz), abs(playerPos.y));
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}

#endif