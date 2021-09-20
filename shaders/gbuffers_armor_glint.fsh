#version 120 

//Varyings//
varying vec2 texCoord;

varying vec4 color;

//Uniforms//
uniform sampler2D texture;

//Program//
void main() {
	vec4 col = texture2D(texture, texCoord.xy) * color;
	
	#if MC_VERSION >= 11500
		col.rgb = pow(col.rgb,vec3(1.6));
		col.rgb *= 0.25;
	#else
		col.rgb = pow(col.rgb,vec3(2.2));
	#endif
	
	col.rgb *= 10.0;
	
    /* DRAWBUFFERS:0 */
	gl_FragData[0] = col;
}
