extends Area2D

@onready var cell_background: Sprite2D = $cell_background
@onready var letter_label: Label = $letter_label

const CELL_SIZE = 60
const COLOR_HIGHLIGHT = Color(0.361, 0.486, 0.392, 1.0)
const COLOR_USED = Color(0.5, 0.5, 0.5, 0.5)

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false
var _border_texture_cache: Texture2D

class TextureGenerator:
	static func create_pixel_art_background(size: Vector2) -> ImageTexture:
		var image := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
		
		for y in range(int(size.y)):
			for x in range(int(size.x)):
				var color := Color(1, 1, 1, 1)
				if (x + y) % 2 == 0:
					color = Color(1, 1, 1, 1)
				image.set_pixel(x, y, color)
		
		return ImageTexture.create_from_image(image)
	
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
	_setup_background()

func _setup_background() -> void:
	if not _border_texture_cache:
		_border_texture_cache = TextureGenerator.create_cell_border(Vector2(CELL_SIZE, CELL_SIZE))
	cell_background.texture = _border_texture_cache
	cell_background.modulate = Color(1, 1, 1, 1)

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	if letter_label:
		letter_label.text = letter

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		modulate = COLOR_USED
		if cell_background:
			cell_background.modulate = Color(0, 0, 0, 0)
		if letter_label:
			letter_label.modulate = Color(0, 0, 0, 0)
	else:
		modulate = Color(1, 1, 1, 1)
		if cell_background:
			if is_highlighted:
				cell_background.modulate = COLOR_HIGHLIGHT
			else:
				cell_background.modulate = Color(1, 1, 1, 1)
		if letter_label:
			letter_label.modulate = Color(1, 1, 1, 1)

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		if cell_background:
			cell_background.modulate = Color(1, 1, 0, 1)
	elif cell_background:
		cell_background.modulate = Color(1, 1, 1, 1)
