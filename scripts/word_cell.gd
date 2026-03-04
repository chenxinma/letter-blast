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

## Sets the letter and coordinate for this cell
## @param char: The letter character to display
## @param coord: The grid coordinate for this cell
func set_letter(char: String, coord: Vector2) -> void:
	letter = char
	coordinate = coord
	letter_label.text = letter

## Sets whether this cell is used
## @param used: True to mark as used, false otherwise
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

## Sets whether this cell is highlighted
## @param highlighted: True to highlight, false otherwise
func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		cell_background.modulate = COLOR_HIGHLIGHT
	else:
		cell_background.modulate = Color(1, 1, 1, 1)

func _ready() -> void:
	connect("_on_mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("_on_mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("_on_input_event", Callable(self, "_on_input_event"))

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

