#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

void main() {
	// Sample the color
	//vec3 color = pow(texture2D(colortex0, texcoord).rgb, vec3(1.0f / 2.2f));

	vec3 color = texture2D(colortex0, texcoord).rgb;
	// Output the color
	gl_FragColor = vec4(color, 1.0f);
}