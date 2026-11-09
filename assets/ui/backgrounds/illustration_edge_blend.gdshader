shader_type canvas_item;

uniform float foreground_start : hint_range(0.0, 0.99) = 0.82;
uniform float source_foreground_start : hint_range(0.0, 1.0) = 0.91;
uniform float fade_start : hint_range(0.0, 0.99) = 0.85;

void fragment() {
	// Preserve the illustration above the foreground, then stretch its lower edge.
	float source_y = UV.y < foreground_start
		? UV.y * source_foreground_start / foreground_start
		: mix(source_foreground_start, 1.0, (UV.y - foreground_start) / (1.0 - foreground_start));
	vec4 illustration = texture(TEXTURE, vec2(UV.x, source_y));
	float fade = smoothstep(fade_start, 1.0, UV.y);
	illustration.rgb *= mix(1.0, 0.76, fade);
	illustration.a *= 1.0 - fade;
	COLOR = illustration;
}
