#version 130

uniform float frameTimeCounter;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying vec2 texcoord;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

	float depth = texture2D(depthtex0, texcoord).r;
    if(depth == 1.0f){
        gl_FragData[0] = vec4(color, 1.0f);
        return;
    }

    vec3 diffuse = color;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(diffuse, 1.0f); //gcolor
}