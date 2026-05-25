// 文档 https://github.com/hooke007/MPV_lazy/wiki/4_GLSL

/*

LICENSE:
  --- RAW ver.
  https://github.com/mergian/dpid/blob/master/LICENSE.txt

*/


//!PARAM LBD
//!TYPE float
//!MINIMUM 0.001
//!MAXIMUM 3.0
1.0


//!HOOK MAIN
//!BIND HOOKED
//!SAVE DPID_REF
//!DESC [DPID_RT] ref
//!WIDTH OUTPUT.w
//!HEIGHT OUTPUT.h
//!WHEN OUTPUT.w HOOKED.w < OUTPUT.h HOOKED.h < *

vec4 hook() {

	return HOOKED_tex(HOOKED_pos);

}

//!HOOK MAIN
//!BIND DPID_REF
//!SAVE DPID_GD
//!DESC [DPID_RT] guide
//!WIDTH DPID_REF.w
//!HEIGHT DPID_REF.h
//!WHEN OUTPUT.w HOOKED.w < OUTPUT.h HOOKED.h < *

vec4 hook() {

	vec3 sum = vec3(0.0);
	sum += DPID_REF_texOff(vec2(-1, -1)).rgb * 1.0;
	sum += DPID_REF_texOff(vec2( 0, -1)).rgb * 2.0;
	sum += DPID_REF_texOff(vec2( 1, -1)).rgb * 1.0;
	sum += DPID_REF_texOff(vec2(-1,  0)).rgb * 2.0;
	sum += DPID_REF_texOff(vec2( 0,  0)).rgb * 4.0;
	sum += DPID_REF_texOff(vec2( 1,  0)).rgb * 2.0;
	sum += DPID_REF_texOff(vec2(-1,  1)).rgb * 1.0;
	sum += DPID_REF_texOff(vec2( 0,  1)).rgb * 2.0;
	sum += DPID_REF_texOff(vec2( 1,  1)).rgb * 1.0;
	return vec4(sum / 16.0, 1.0);

}

//!HOOK MAIN
//!BIND HOOKED
//!BIND DPID_GD
//!DESC [DPID_RT] dscale
//!WIDTH OUTPUT.w
//!HEIGHT OUTPUT.h
//!WHEN OUTPUT.w HOOKED.w < OUTPUT.h HOOKED.h < *

vec4 hook() {

	vec3 guidance = DPID_GD_tex(DPID_GD_pos).rgb;

	const vec2 inv_scale = HOOKED_size / target_size;
	const vec2 src_pixel_size = HOOKED_pt;

	vec2 region_start_uv = (gl_FragCoord.xy - 0.5) * inv_scale * src_pixel_size;
	vec2 region_end_uv = (gl_FragCoord.xy + 0.5) * inv_scale * src_pixel_size;

	ivec2 start_px = ivec2(floor(region_start_uv / src_pixel_size));
	ivec2 end_px = ivec2(ceil(region_end_uv / src_pixel_size));

	vec3 color_sum = vec3(0.0);
	float weight_sum = 0.0;
	const float Vmax = sqrt(3.0);

	for (int y = start_px.y; y < end_px.y; ++y) {
		for (int x = start_px.x; x < end_px.x; ++x) {
			vec2 current_px_coord = vec2(x, y) + 0.5;
			vec3 color = texelFetch(HOOKED_raw, ivec2(x, y), 0).rgb;
			float coverage_x = max(0.0, min((current_px_coord.x + 0.5), region_end_uv.x / src_pixel_size.x) - max((current_px_coord.x - 0.5), region_start_uv.x / src_pixel_size.x));
			float coverage_y = max(0.0, min((current_px_coord.y + 0.5), region_end_uv.y / src_pixel_size.y) - max((current_px_coord.y - 0.5), region_start_uv.y / src_pixel_size.y));
			float contribution = coverage_x * coverage_y;
			float dist = length(color - guidance);
			float weight = pow(dist / Vmax, LBD);
			color_sum += color * weight * contribution;
			weight_sum += weight * contribution;
		}
	}

	if (weight_sum < 1e-6) {
		return vec4(guidance, 1.0);
	} else {
		return vec4(color_sum / weight_sum, 1.0);
	}

}

