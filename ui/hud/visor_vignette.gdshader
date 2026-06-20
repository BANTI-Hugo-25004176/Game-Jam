shader_type canvas_item;

// Helmet-visor vignette: darkens + amber-tints the screen edges (Fallout power-armor feel).
// Applied to a full-screen ColorRect that stays transparent in the centre.

uniform vec4 edge_tint : source_color = vec4(0.22, 0.11, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.55;
uniform float radius : hint_range(0.1, 1.2) = 0.82;
uniform float softness : hint_range(0.05, 0.8) = 0.45;

void fragment() {
	vec2 uv = UV - 0.5;
	// slight horizontal stretch so it reads like a wide visor
	float dist = length(uv * vec2(1.15, 1.0));
	float v = smoothstep(radius - softness, radius, dist);
	COLOR = vec4(edge_tint.rgb, v * intensity);
}
