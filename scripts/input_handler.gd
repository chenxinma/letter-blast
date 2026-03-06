class_name InputHandler

extends Node

@export var cell_size: int = 60
@export var grid_manager: GridManager
@export var word_manager: WordManager

var selected_path: Array[Vector2] = []
var current_word: String = ""

signal word_validated(word: String, is_valid: bool)


func handle_mouse_press(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = mouse_to_grid(event.position)
		select_cell(grid_pos)


func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not selected_path.is_empty():
		var grid_pos = mouse_to_grid(event.position)
		select_cell(grid_pos)


func handle_mouse_release(event: InputEventMouseButton) -> void:
	print("handle_mouse_release")
	if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if selected_path.size() >= 2:
			validate_word()
		else:
			clear_selection()


func select_cell(coord: Vector2) -> void:
	if not grid_manager.is_valid_coordinate(coord):
		return
	
	var cell = grid_manager.get_cell(coord)
	if cell == null or cell.is_used:
		return

	if selected_path.is_empty():
		selected_path.append(coord)
		cell.set_highlighted(true)
	else:
		if is_adjacent_to_last(coord) and not coord in selected_path:
			selected_path.append(coord)
			cell.set_highlighted(true)
	
	update_current_word()


func is_adjacent_to_last(coord: Vector2) -> bool:
	if selected_path.is_empty():
		return false
	
	var last_coord = selected_path[-1]
	var dx = abs(coord.x - last_coord.x)
	var dy = abs(coord.y - last_coord.y)
	
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)


func update_current_word() -> void:
	current_word = ""
	for coord in selected_path:
		var cell = grid_manager.get_cell(coord)
		if cell != null:
			current_word += cell.letter


func validate_word() -> void:
	if current_word.length() >= 2:
		if word_manager.is_valid_word(current_word):
			grid_manager.mark_cells_as_used(selected_path)
			word_manager.mark_as_found(current_word)
			emit_signal("word_validated", current_word, true)
		else:
			emit_signal("word_validated", current_word, false)
	
	clear_selection()


func clear_selection() -> void:
	for coord in selected_path:
		var cell = grid_manager.get_cell(coord)
		if cell != null:
			cell.set_highlighted(false)
	selected_path.clear()
	current_word = ""
	print("clear_selection")


func mouse_to_grid(mouse_pos: Vector2) -> Vector2:
	var grid_position := grid_manager.position
	var relative_pos := mouse_pos - grid_position
	return Vector2(int(ceil(relative_pos.x / cell_size)) - 1,
				   int(ceil(relative_pos.y / cell_size)) - 1)
