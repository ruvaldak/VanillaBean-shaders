#version 120

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//Pass vertex information to fragment shader.
varying vec4 glcolor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

uniform int frameCounter;

uniform float viewWidth, viewHeight;

#include "bsl_lib/util/jitter.glsl"

void main() {
	gl_Position = ftransform();
    
    glcolor = gl_Color;
    
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	
	gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
