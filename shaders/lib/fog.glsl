/*
Only works in GBuffers
Requires these things to be set before the main function:
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;
*/
vec4 fog;

if(MC_VERSION >= 11700)
    fog.a = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);
else {
    if(fogMode == GL_EXP) //exponential fog
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density);
    else if (fogMode == GL_LINEAR) //linear fog
        fog.a = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);
    else if (isEyeInWater == 1.0 || isEyeInWater == 2.0)
        fog.a = 1.-exp(-gl_FogFragCoord * gl_Fog.density); //denser underwater and underlava fog
}
fog.rgb = gl_Fog.color.rgb;

//Apply the fog.
col.rgb = mix(col.rgb, fog.rgb, fog.a);
