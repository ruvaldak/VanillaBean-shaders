#version 130

varying vec4 color;
varying vec2 coord0;
uniform float frameTimeCounter;


void main()
{
    gl_Position = ftransform();

    color = gl_Color;
    coord0 = (gl_MultiTexCoord0).xy;
}
