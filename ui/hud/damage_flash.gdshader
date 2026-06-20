shader_type canvas_item;

// Red "hurt" vignette: red at the screen edges, controlled by `amount` (0..1).
// Driven by damage_flash.gd, which tweens `amount` up then back to 0 on a hit.

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float inner : hint_range(0.0, 1.0) = 0.35;
uniform float outer : hint_range(0.0, 1.2) = 0.78;

void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv * vec2(1.15, 1.0));
	float v = smoothstep(inner, outer, dist);
	COLOR = vec4(0.75, 0.02, 0.02, v * amount);
}
