shader_type canvas_item;

uniform vec3 rgb : source_color;
uniform float pulse_enabled: hint_range(0.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
	
	float dist = length(uv - center) - 0.2;
	float pulse = sin(TIME * 1.5) * pulse_enabled - 0.6 * (1.0 - pulse_enabled);
	COLOR = vec4(rgb, 0.2 + pulse * dist);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
