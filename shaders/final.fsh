#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

void main() {
	// Sample the color
	vec3 color = texture2D(colortex0, texcoord).rgb;

	// Convert to grayscale
	color = vec3(dot(color, vec3(0.333f)));

	// Output the color
	gl_FragColor = vec4(color, 1.0f);
}