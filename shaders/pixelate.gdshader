shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float pixel_size : hint_range(1.0, 64.0);

void fragment() {
	ivec2 screen_size = textureSize(screen_texture, 0);
	vec2 pixel_coord = SCREEN_UV * vec2(screen_size);
	pixel_coord = floor(pixel_coord / pixel_size) * pixel_size + pixel_size;
	vec2 pixelated_uv = pixel_coord / vec2(screen_size);
	COLOR = texture(screen_texture, pixelated_uv);
}