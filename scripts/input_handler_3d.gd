extends Node

signal word_validated(word: String, is_valid: bool)

var grid_manager: GridManager3D
var word_manager: WordManager
var selected_path: Array[Vector2] = []
var current_word: String = ""

func handle_mouse_press(event: InputEvent) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		select_cell(cell.coordinate)

func handle_mouse_release(event: InputEvent) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT or event.pressed:
		return
	
	if selected_path.size() >= 2:
		validate_word()
	else:
		clear_selection()

func handle_mouse_motion(event: InputEvent) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or selected_path.is_empty():
		return
	
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		select_cell(cell.coordinate)

func _get_cell_under_mouse(mouse_pos: Vector2) -> Node:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	var to = from + normal * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 2
	
	var result = space_state.intersect_ray(query)
	if result and result.has("collider"):
		return result["collider"]
	return null

func select_cell(coord: Vector2) -> void:
	if not grid_manager.is_valid_coordinate(coord):
		return
	
	var cell = grid_manager.get_cell_at(coord)
	if cell == null or cell.is_used:
		return
	
	if selected_path.is_empty():
		selected_path.append(coord)
		cell.set_highlighted(true)
	else:
		if _is_adjacent_to_last(coord) and not coord in selected_path:
			selected_path.append(coord)
			cell.set_highlighted(true)
	
	_update_current_word()

func _is_adjacent_to_last(coord: Vector2) -> bool:
	if selected_path.is_empty():
		return false
	
	var last_coord = selected_path[-1]
	var dx = abs(coord.x - last_coord.x)
	var dy = abs(coord.y - last_coord.y)
	
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1) or (dx == 1 and dy == 1)

func _update_current_word() -> void:
	current_word = ""
	for coord in selected_path:
		var cell = grid_manager.get_cell_at(coord)
		if cell != null:
			current_word += cell.letter

func validate_word() -> void:
	if current_word.length() >= 2:
		if word_manager.is_valid_word(current_word):
			grid_manager.mark_used(selected_path)
			word_manager.mark_as_found(current_word)
			emit_signal("word_validated", current_word, true)
		else:
			emit_signal("word_validated", current_word, false)
	
	clear_selection()

func clear_selection() -> void:
	for coord in selected_path:
		var cell = grid_manager.get_cell_at(coord)
		if cell != null:
			cell.set_highlighted(false)
	selected_path.clear()
	current_word = ""
