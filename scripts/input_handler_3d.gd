extends Node

signal word_validated(word: String, is_valid: bool)

var grid_manager: GridManager3D
var word_manager: WordManager
var is_selecting: bool = false
var selection_start_coord: Vector2 = Vector2(-1, -1)

func handle_mouse_press(event: InputEvent) -> void:
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		is_selecting = true
		selection_start_coord = cell.coordinate
		grid_manager.highlight_cell(cell.coordinate, true)

func handle_mouse_release(_event: InputEvent) -> void:
	if not is_selecting:
		return
	
	is_selecting = false
	
	var word = grid_manager.get_selected_letters()
	var coords = grid_manager.get_selected_coordinates()
	
	if word.length() > 0:
		var is_valid = word_manager.is_valid_word(word)
		emit_signal("word_validated", word, is_valid)
		
		if is_valid:
			grid_manager.mark_used(coords)
	
	grid_manager.clear_highlights()
	selection_start_coord = Vector2(-1, -1)

func handle_mouse_motion(event: InputEvent) -> void:
	if not is_selecting:
		return
	
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		var current_coord = cell.coordinate
		if current_coord != selection_start_coord:
			_handle_line_selection(selection_start_coord, current_coord)

func _get_cell_under_mouse(mouse_pos: Vector2) -> Node:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_viewport().world_3d.direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.has("collider"):
		return result["collider"]
	return null

func _handle_line_selection(start: Vector2, end: Vector2) -> void:
	grid_manager.clear_highlights()
	
	var cells_in_line = _get_cells_in_line(start, end)
	for coord in cells_in_line:
		grid_manager.highlight_cell(coord, true)

func _get_cells_in_line(start: Vector2, end: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	var dx = int(end.x - start.x)
	var dy = int(end.y - start.y)
	var steps = max(abs(dx), abs(dy))
	
	if steps == 0:
		result.append(start)
		return result
	
	var x_inc = dx / steps
	var y_inc = dy / steps
	
	for i in range(steps + 1):
		var coord = Vector2(int(start.x) + i * x_inc, int(start.y) + i * y_inc)
		result.append(coord)
	
	return result
