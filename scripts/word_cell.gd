extends Area2D

@onready var cell_background: Sprite2D = $cell_background
@onready var letter_label: Label = $letter_label

var letter: String = ""
var coord: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false

signal cell_selected

func set_letter(char: String, coord: Vector2) -> void:
	letter = char
	coord = coordinate
	letter_label.text = letter

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		modulate = Color(0.5, 0.5, 0.5, 0.5)
		cell_background.modulate = Color(0, 0, 0, 0)
		letter_label.modulate = Color(0, 0, 0, 0)
	else:
		modulate = Color(1, 1, 1, 1)
		if is_highlighted:
			cell_background.modulate = Color(1, 0.8, 0, 1)
		else:
			cell_background.modulate = Color(1, 1, 1, 1)
		letter_label.modulate = Color(1, 1, 1, 1)

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		cell_background.modulate = Color(1, 0.8, 0, 1)
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
				emit_signal("cell_selected", self, letter, coord)
				set_used(true)

