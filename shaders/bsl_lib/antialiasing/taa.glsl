/* 
BSL Shaders v8.1.01 by Capt Tatsu 
https://bitslablab.com 
*/ 

//Previous frame reprojection from Chocapic13
vec2 Reprojection(vec3 pos) {
	pos = pos * 2.0 - 1.0;

	vec4 viewPosPrev = gbufferProjectionInverse * vec4(pos, 1.0);
	viewPosPrev /= viewPosPrev.w;
	viewPosPrev = gbufferModelViewInverse * viewPosPrev;

	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	cameraOffset *= float(pos.z > 0.56);

	vec4 previousPosition = viewPosPrev + vec4(cameraOffset, 0.0);
	previousPosition = gbufferPreviousModelView * previousPosition;
	previousPosition = gbufferPreviousProjection * previousPosition;
	return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}

vec2 neighbourhoodOffsets[8] = vec2[8](
	vec2( 0.0, -1.0),
	vec2(-1.0,  0.0),
	vec2( 1.0,  0.0),
	vec2( 0.0,  1.0),
	vec2(-1.0, -1.0),
	vec2( 1.0, -1.0),
	vec2(-1.0,  1.0),
	vec2( 1.0,  1.0)
);

vec3 RGBToYCoCg(vec3 col) {
	return vec3(
		col.r * 0.25 + col.g * 0.5 + col.b * 0.25,
		col.r * 0.5 - col.b * 0.5,
		col.r * -0.25 + col.g * 0.5 + col.b * -0.25
	);
}

vec3 YCoCgToRGB(vec3 col) {
	float n = col.r - col.b;
	return vec3(n + col.g, col.r + col.b, n - col.g);
}

vec3 ClipAABB(vec3 q,vec3 aabb_min, vec3 aabb_max){
	vec3 p_clip = 0.5 * (aabb_max + aabb_min);
	vec3 e_clip = 0.5 * (aabb_max - aabb_min) + 0.00000001;

	vec3 v_clip = q - vec3(p_clip);
	vec3 v_unit = v_clip.xyz / e_clip;
	vec3 a_unit = abs(v_unit);
	float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));

	if (ma_unit > 1.0)
		return vec3(p_clip) + v_clip / ma_unit;
	else
		return q;
}

vec3 NeighbourhoodClamping(vec3 color, vec3 tempColor, vec2 view) {
	vec3 minclr = RGBToYCoCg(color);
	vec3 maxclr = minclr;

	for(int i = 0; i < 8; i++) {
		vec2 offset = neighbourhoodOffsets[i] * view;
		vec3 clr = texture2DLod(colortex1, texCoord + offset, 0.0).rgb;

		clr = RGBToYCoCg(clr);
		minclr = min(minclr, clr); maxclr = max(maxclr, clr);
	}

	tempColor = RGBToYCoCg(tempColor);
	tempColor = ClipAABB(tempColor, minclr, maxclr);

	return YCoCgToRGB(tempColor);
}

vec4 TemporalAA(inout vec3 color, float tempData) {
	vec3 coord = vec3(texCoord, texture2DLod(depthtex1, texCoord, 0.0).r);
	vec2 prvCoord = Reprojection(coord);
	
	vec3 tempColor = texture2DLod(colortex2, prvCoord, 0).gba;
	vec2 view = vec2(viewWidth, viewHeight);

	if(tempColor == vec3(0.0)){
		return vec4(tempData, color);
	}
	
	tempColor = NeighbourhoodClamping(color, tempColor, 1.0 / view);
	
	vec2 velocity = (texCoord - prvCoord.xy) * view;
	float blendFactor = float(
		prvCoord.x > 0.0 && prvCoord.x < 1.0 &&
		prvCoord.y > 0.0 && prvCoord.y < 1.0
	);
	blendFactor *= exp(-length(velocity)) * 0.6 + 0.3;
	
	color = mix(color, tempColor, blendFactor);
	return vec4(tempData, color);
}