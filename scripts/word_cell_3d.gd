extends Area3D

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var label_3d: Label3D = $Label3D

const CELL_SIZE = 60
const COLOR_HIGHLIGHT = Color(0.361, 0.486, 0.392, 1.0)
const COLOR_HINT = Color(0.934, 0.837, 0.941, 1.0)
const COLOR_USED = Color(0.5, 0.5, 0.5, 0.5)

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false
var _border_texture_cache: Texture2D

class TextureGenerator:
	static func create_cell_border(size: Vector2) -> ImageTexture:
		var image := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 1, 1, 1))
		
		for x in range(int(size.x)):
			image.set_pixel(x, 0, Color(0, 0, 0, 1))
			image.set_pixel(x, int(size.y) - 1, Color(0, 0, 0, 1))
		
		for y in range(int(size.y)):
			image.set_pixel(0, y, Color(0, 0, 0, 1))
			image.set_pixel(int(size.x) - 1, y, Color(0, 0, 0, 1))
		
		return ImageTexture.create_from_image(image)

func _ready() -> void:
	_setup_sprite()

func _setup_sprite() -> void:
	if not _border_texture_cache:
		_border_texture_cache = TextureGenerator.create_cell_border(Vector2(CELL_SIZE, CELL_SIZE))
	sprite_3d.texture = _border_texture_cache
	sprite_3d.modulate = Color(1.0, 1.0, 1.0, 0.5)

func set_hint() -> void:
	sprite_3d.modulate = COLOR_HINT

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	if label_3d:
		label_3d.text = letter

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		if sprite_3d:
			sprite_3d.modulate = Color(0, 0, 0, 0)
		if label_3d:
			label_3d.modulate = Color(0, 0, 0, 0)
	else:
		if sprite_3d:
			if is_highlighted:
				sprite_3d.modulate = COLOR_HIGHLIGHT
			else:
				sprite_3d.modulate = Color(1, 1, 1, 1)
		if label_3d:
			label_3d.modulate = Color(1, 1, 1, 1)

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		if sprite_3d:
			sprite_3d.modulate = Color(1, 1, 0, 1)
	elif sprite_3d:
		sprite_3d.modulate = Color(1, 1, 1, 1)

func get_world_position() -> Vector3:
	return global_position