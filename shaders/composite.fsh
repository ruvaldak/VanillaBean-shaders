#version 120

varying vec2 texcoord;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;

// color textures:
uniform sampler2D colortex0; // buffer 0 (color)
uniform sampler2D colortex1; // buffer 1 (normal vector)
uniform sampler2D colortex2; // buffer 2 (lightmap)

//color formats, define color channels here per buffer
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

const float sunPathRotation = 0.0f;

float Ambient = 0.025f;

//adjust lightmap. might remove later, trying to get accurate vanilla lighting
float AdjustLightmapTorch(in float torch) {
	const float K = 2.0f;
	const float P = 5.06f;
	return K * pow(torch, P);
}

float AdjustLightmapSky(in float sky) {
	float sky_2 = float(pow(sky, 2));
	return float(pow(sky_2, 2));
}

vec2 AdjustLightmap(in vec2 lightmap) {
	/*
	vec2 newLightmap;
	newLightmap.x = AdjustLightmapTorch(lightmap.x);
	newLightmap.y = AdjustLightmapSky(lightmap.y);
	*/
	return vec2(AdjustLightmapTorch(lightmap.x), AdjustLightmapSky(lightmap.y));
}

vec3 GetLightmapColor(in vec2 lightmap) {
	//adjust lightmap
	lightmap = AdjustLightmap(lightmap);

	//color of torch and sky, sky color changes depending on time, ignored for simplicity for now
	const vec3 torchColor = vec3(1.0f, 0.25f, 0.08f);
	const vec3 skyColor = vec3(0.05f, 0.15f, 0.3f);

	//multiply each part of the lightmap with it's color
	vec3 torchLighting = lightmap.x * torchColor;
	vec3 skyLighting = lightmap.y * skyColor;

	//add lighting together
	vec3 lightmapLighting = torchLighting + skyLighting;

	return lightmapLighting;
}

void main() {
	// albedo accounting for gamma correction
	//vec3 albedo = pow(texture2D(colortex0, texcoord).rgb, vec3(2.2f));

	//albedo
	vec3 albedo = texture2D(colortex0, texcoord).rgb;

	//normalize normal vector
	vec3 normal = normalize(texture2D(colortex1, texcoord).rgb * 2.0f - 1.0f);

	//compute cos theta between normal and sun directions
	float NdotL = max(dot(normal, normalize(sunPosition)), 0.0f);

	//lightmap.x = torch lighting, lightmap.y = sky lighting
	vec2 lightmap = texture2D(colortex2, texcoord).rg;
	//vec3 lightmap = vec3(texture2D(colortex2, texcoord).rg, 0.0f);

	// get lightmap color
	vec3 lightmapColor = GetLightmapColor(lightmap);

	Ambient = 1.0f;

	//do lighting. albedo = block color. multiply by modifiers.
	vec3 diffuse = albedo * (lightmapColor * NdotL + Ambient);

	/* DRAWBUFFERS:0 */
	//gl_FragData[0] = vec4(diffuse, 1.0f);
	gl_FragData[0] = vec4(diffuse, 1.0f);
}