#version 120 

//Varyings//
varying vec2 texCoord;

//Uniforms//
uniform sampler2D texture;

//Program//
void main() {
	vec4 col = texture2D(texture, texCoord.xy);
	
    /* DRAWBUFFERS:0 */
	gl_FragData[0] = col;
}