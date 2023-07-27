shader_type spatial;

uniform vec2 center;
uniform float force;

void fragment() {
	float mask = (.1 - smoothstep(0.1, 0.11, length(UV - center))) * smoothstep(0.08, 0.09, length(UV - center));
	vec2 disp = normalize(UV - center) * force * mask;
	ALBEDO = vec3(UV - disp, 0);
}