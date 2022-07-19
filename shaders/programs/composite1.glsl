#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D depthtex0;
uniform float far;

#include "/settings.glsl"

//varying vec2 texCoord;

in vec4 color;
in vec2 coord0;

const bool colortex2Clear = false;

void main()
{
    vec4 col = color;
    float temporalData = 0.0;
    vec3 temporalColor = texture2D(colortex2, coord0).gba;

    /*DRAWBUFFERS:12*/
    gl_FragData[0] = col * texture2D(colortex0,coord0);
    gl_FragData[1] = vec4(temporalData,temporalColor);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

out vec4 color;
out vec2 coord0;
uniform float frameTimeCounter;


void main()
{
    gl_Position = ftransform();

    color = gl_Color;
    coord0 = (gl_MultiTexCoord0).xy;
}

#endif