#version 120 

//Varyings//
varying vec2 texCoord;

varying vec4 color;

//Uniforms//
uniform sampler2D texture;

//Program//
void main() {
	vec4 col = texture2D(texture, texCoord.xy) * color;	

    /* DRAWBUFFERS:0 */
	gl_FragData[0] = col;
}