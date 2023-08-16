shader_type spatial;

uniform sampler2D texture_albedo : source_color;

void fragment() {
	vec2 base_uv = UV;
	base_uv.x += sin(mod(TIME * 24.0, PI * 2.0)) * pow(1.0-base_uv.y,1.5) * .25;
	
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}