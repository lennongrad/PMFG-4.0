shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
 
uniform vec4 main_color : source_color;
uniform vec4 intersection_color : source_color;
uniform float intersection_max_threshold = 0.5;
uniform sampler2D displ_tex : hint_default_white;
uniform float displ_amount = 0.6;
uniform float near = 0.15;
uniform float far = 300.0;
 
float linearize(float c_depth) {
	c_depth = 2.0 * c_depth - 1.0;
	return near * far / (far + c_depth * (near - far));
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX.y += cos(TIME + VERTEX.x * 1.0 + VERTEX.z * 1.0) * .1;
	VERTEX.y += texture(displ_tex, (UV - TIME / 7.0) / 14.0).r * .1;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv - TIME / 14.0);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float zpos = linearize(FRAGCOORD.z);
	float diff = zdepth - zpos;
 
	ALBEDO = vec3(diff);
	vec2 displ = texture(displ_tex, UV - TIME / 7.0).rg;
	displ = ((displ * 2.0) - 1.0) * displ_amount;
	diff += displ.x;
	
	vec4 tx = albedo_tex.rgba;
	tx.rgb += vec3(displ.x, displ.x, displ.y) * .05;
 
	vec4 col = mix(intersection_color, tx, step(intersection_max_threshold, diff));
	ALBEDO = col.rgb;
 	ALPHA = .8;
}
