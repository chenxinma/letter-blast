extends Area3D

@onready var letter_label: Label3D = $LetterLabel
@onready var button_mesh: MeshInstance3D = $Button

const CELL_SIZE = 60
const COLOR_HIGHLIGHT = Color(0.361, 0.486, 0.392, 1.0)
const COLOR_HINT = Color(0.643, 0.349, 0.671, 0.5)
const COLOR_USED = Color(0.5, 0.5, 0.5, 0.5)
const COLOR_NORMAL = Color(0.8, 0.7, 0.5, 1)

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false

func _ready() -> void:
	_setup_sprite()

func _setup_sprite() -> void:
	pass

func set_hint() -> void:
	pass

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	if letter_label and letter.length() == 1:
		letter_label.text = letter.to_upper()

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		if letter_label:
			letter_label.modulate = Color(0.3, 0.3, 0.3, 0.5)
		if button_mesh:
			button_mesh.visible = false
	else:
		if letter_label:
			letter_label.modulate = Color(1, 1, 1, 1)
		if button_mesh:
			button_mesh.visible = true

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return

func get_world_position() -> Vector3:
	return global_position
