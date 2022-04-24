#version 120

uniform sampler2D lightmap;
uniform sampler2D noisetex;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;
varying float blockId;

uniform sampler2D texture;
uniform float viewWidth, viewHeight;

void main() {
	/*
	float pi = 6.28318530718f;
	float directions = 16.0f;
	float quality = 4.0f;
	float size = 16.0f;

	vec2 uv = texcoord;

	vec2 radius = size/vec2(viewWidth, viewHeight);

	float randomAngle = texture2D(noisetex, uv * 20.0f).r * 100.0f;
	float cosTheta = cos(randomAngle);
	float sinTheta = sin(randomAngle);
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
	for( float d=0.0; d<pi; d+=pi/directions)
    {
		for(float i=1.0/quality; i<=1.0; i+=1.0/quality)
       	{
			uv += texcoord+(rotation * vec2(cos(d),sin(d))*radius*i);
       	}
    }
    uv /= quality * directions - 15.0;
	*/
	vec4 albedo = texture2D(texture, texcoord) * color;
	vec4 light = vec4(texture2D(lightmap,lmcoord).rgb, 1.0f);
	albedo *= light;
	//albedo.r *= 6;

	/* DRAWBUFFERS:014 */
	gl_FragData[0] = albedo;
	gl_FragData[1] = vec4(normal, 1.0f);
	gl_FragData[2] = vec4(blockId, 0.0f, 0.0f, 1.0f);
	//gl_FragData[3] = color;
}