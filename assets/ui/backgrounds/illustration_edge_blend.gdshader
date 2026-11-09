shader_type canvas_item;

uniform float extra_sky : hint_range(0.0, 0.95) = 0.0;

uniform float foreground_start : hint_range(0.0, 0.99) = 0.82;
uniform float source_foreground_start : hint_range(0.0, 1.0) = 0.91;
uniform float fade_start : hint_range(0.0, 0.99) = 0.85;

void fragment() {
	// Grow the empty sky on tall screens so the children and board keep their proportions.
	const float SKY_END = 0.34;
	float expanded_sky_end = mix(SKY_END, 1.0, extra_sky);
	float illustration_y = UV.y < expanded_sky_end
		? UV.y * SKY_END / expanded_sky_end
		: (UV.y - extra_sky) / (1.0 - extra_sky);
	float source_y = illustration_y < foreground_start
		? illustration_y * source_foreground_start / foreground_start
		: mix(source_foreground_start, 1.0, (illustration_y - foreground_start) / (1.0 - foreground_start));
	vec4 illustration = texture(TEXTURE, vec2(UV.x, source_y));
	float fade = smoothstep(fade_start, 1.0, UV.y);
	illustration.rgb *= mix(1.0, 0.76, fade);
	illustration.a *= 1.0 - fade;
	COLOR = illustration;
}
