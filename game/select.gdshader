shader_type canvas_item;

uniform bool selected;
uniform vec3 rgb : source_color;

void fragment() {
	COLOR = vec4(rgb, float(selected) * 0.5);
}
