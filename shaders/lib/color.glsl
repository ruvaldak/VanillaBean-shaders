float linearLuminance(vec3 rgb)
{
    // Algorithm from Chapter 10 of Graphics Shaders.
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

// https://www.titanwolf.org/Network/q/bb468365-7407-4d26-8441-730aaf8582b5/x
vec3 linearTosRGB(vec3 linear) {
    vec3 higher = (pow(abs(linear), vec3(1.0 / 2.4)) * 1.055) - 0.055;
    vec3 lower  = linear * 12.92;
    return mix(higher, lower, step(linear, vec3(0.0031308)));
}

vec3 sRGBToLinear(vec3 sRGB) {
    vec3 higher = pow((sRGB + 0.055) / 1.055, vec3(2.4));
    vec3 lower  = sRGB / 12.92;
    return mix(higher, lower, step(sRGB, vec3(0.04045)));
}