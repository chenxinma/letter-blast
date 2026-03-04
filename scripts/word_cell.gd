extends Area2D

@onready var cell_background: Sprite2D = $cell_background
@onready var letter_label: Label = $letter_label

const COLOR_HIGHLIGHT = Color(1, 0.8, 0, 1)
const COLOR_USED = Color(0.5, 0.5, 0.5, 0.5)

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false

signal cell_selected

class TextureGenerator:
	static func create_pixel_art_background(size: Vector2, cell_size: int) -> ImageTexture:
		var texture := ImageTexture.new()
		var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		
		for y in range(size.y):
			for x in range(size.x):
				var color := Color(1, 1, 1, 0.1)
				if (x + y) % 2 == 0:
					color = Color(0.9, 0.9, 1, 0.3)
				image.set_pixel(x, y, color)
		
		texture.create_from_image(image, 0)
		return texture
	
	static func create_cell_border(size: Vector2) -> ImageTexture:
		var texture := ImageTexture.new()
		var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))
		
		for x in range(size.x):
			image.set_pixel(x, 0, Color(0.2, 0.2, 0.2, 0.5))
			image.set_pixel(x, size.y - 1, Color(0.2, 0.2, 0.2, 0.5))
		
		for y in range(size.y):
			image.set_pixel(0, y, Color(0.2, 0.2, 0.2, 0.5))
			image.set_pixel(size.x - 1, y, Color(0.2, 0.2, 0.2, 0.5))
		
		texture.create_from_image(image, 0)
		return texture

func _ready() -> void:
	_setup_background()
	connect("_on_mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("_on_mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("_on_input_event", Callable(self, "_on_input_event"))

func _setup_background() -> void:
	var border_texture := TextureGenerator.create_cell_border(Vector2(40, 40))
	cell_background.texture = border_texture
	cell_background.modulate = Color(1, 1, 1, 1)

func set_letter(char: String, coord: Vector2) -> void:
	letter = char
	coordinate = coord
	letter_label.text = letter

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		modulate = COLOR_USED
		cell_background.modulate = Color(0, 0, 0, 0)
		letter_label.modulate = Color(0, 0, 0, 0)
	else:
		modulate = Color(1, 1, 1, 1)
		if is_highlighted:
			cell_background.modulate = COLOR_HIGHLIGHT
		else:
			cell_background.modulate = Color(1, 1, 1, 1)
		letter_label.modulate = Color(1, 1, 1, 1)

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		cell_background.modulate = COLOR_HIGHLIGHT
	else:
		cell_background.modulate = Color(1, 1, 1, 1)

func _on_mouse_entered() -> void:
	if not is_used:
		set_highlighted(true)

func _on_mouse_exited() -> void:
	if not is_used:
		set_highlighted(false)

func _on_input_event(event_input: InputEvent) -> void:
	if event_input is InputEventMouseButton:
		var mouse_event := event_input as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if not is_used:
				cell_selected.emit()
				set_used(true)
