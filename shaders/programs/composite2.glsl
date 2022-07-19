#ifdef FSH
/*----------- FRAGMENT SHADER -----------*/

uniform sampler2D texture;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float viewWidth, viewHeight, aspectRatio;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferPreviousProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView, gbufferModelViewInverse;

in vec4 color;
in vec2 texCoord;

#include "/bsl_lib/antialiasing/taa.glsl"

void main()
{
    vec3 color = texture2DLod(colortex1, texCoord, 0.0).rgb;
    vec4 prev = vec4(texture2DLod(colortex2, texCoord, 0).r, 0.0, 0.0, 0.0);

    prev = TemporalAA(color, prev.r);

    /*DRAWBUFFERS:12*/
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(prev);
}

#elif defined VSH
/*----------- VERTEX SHADER -----------*/

out vec4 color;
out vec2 texCoord;

void main()
{
    gl_Position = ftransform();

    color = gl_Color;
    texCoord = (gl_MultiTexCoord0).xy;
}

#endif