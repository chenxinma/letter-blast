extends Node2D
class_name GridManager2D

@export var grid_width: int = 15
@export var grid_height: int = 4
@export var cell_spacing: float = 75.0

var cell_template: PackedScene
var cells: Dictionary = {}
var selected_cells: Array[Node] = []
var placed_paths: Dictionary = {}
var game_words: Array = []

const CELL_SIZE_2D = 1.0
const MAX_PLACEMENT_ATTEMPTS: int = 100
const MAX_RECURSION_DEPTH: int = 30

enum Direction {
	DOWN = 0,
	RIGHT,
	UP,
	LEFT
}

const DIRECTIONS: Array[Vector2] = [
	Vector2(0, 1),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(-1, 0)
]


func set_game_words(words: Array) -> void:
	game_words = words


func generate_grid() -> void:
	clear_grid()
	placed_paths.clear()
	
	for row in range(grid_height):
		for col in range(grid_width):
			cells[Vector2(col, row)] = null
	
	if cell_template == null:
		print("ERROR: cell_template is null")
		return
	
	for word in game_words:
		place_word_in_grid(word)
	
	for row in range(grid_height):
		for col in range(grid_width):
			var coord := Vector2(col, row)
			if cells[coord] == null:
				var cell_instance = cell_template.instantiate()
				add_child(cell_instance)
				
				var pos_x = (col - grid_width / 2.0 + 0.5) * cell_spacing
				var pos_y = (row - grid_height / 2.0 + 0.5) * cell_spacing
				cell_instance.position = Vector2(pos_x, pos_y)
				
				var c = get_random_letter()
				cell_instance.set_letter(c, coord)
				cells[coord] = cell_instance


func get_random_letter() -> String:
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	return letters[randi() % letters.length()]


func place_word_in_grid(word: String) -> bool:
	if word.is_empty():
		return false
	
	for _i in range(MAX_PLACEMENT_ATTEMPTS):
		var start_x := randi() % grid_width
		var start_y := randi() % grid_height
		var start_coord := Vector2(start_x, start_y)
		
		if not can_place_char_at(start_coord, word[0]):
			continue
		
		var path: Array[Vector2] = [start_coord]
		var visited: Dictionary = {start_coord: true}
		
		if try_place_word_recursive(word, 1, start_coord, Vector2.ZERO, path, visited):
			placed_paths[word] = path.duplicate()
			return true
	
	print("单词放置失败: ", word)
	return false


func try_place_word_recursive(word: String, char_index: int, prev_coord: Vector2, prev_direction: Vector2, path: Array[Vector2], visited: Dictionary) -> bool:
	if char_index >= word.length():
		do_place_word_by_path(word, path)
		return true
	
	if path.size() >= MAX_RECURSION_DEPTH:
		return false
	
	var available_directions := get_available_directions(prev_coord, prev_direction, visited)
	if available_directions.is_empty():
		return false
	
	available_directions.shuffle()
	
	for direction in available_directions:
		var next_coord := prev_coord + direction
		
		if not can_place_char_at(next_coord, word[char_index]):
			continue
		
		path.append(next_coord)
		visited[next_coord] = true
		
		if try_place_word_recursive(word, char_index + 1, next_coord, direction, path, visited):
			return true
		
		path.erase(next_coord)
		visited.erase(next_coord)
	
	return false


func get_available_directions(current_coord: Vector2, prev_direction: Vector2, visited: Dictionary) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var opposite := prev_direction * -1
	
	for direction in DIRECTIONS:
		if direction == opposite:
			continue
		
		var next_coord := current_coord + direction
		
		if not is_valid_coordinate(next_coord):
			continue
		
		if visited.has(next_coord):
			continue
		
		result.append(direction)
	
	return result


func can_place_char_at(coord: Vector2, letter: String) -> bool:
	if not is_valid_coordinate(coord):
		return false
	
	var cell := get_cell_at(coord)
	
	if cell == null:
		return true
	
	if cell.is_used:
		return false
	
	return cell.letter == letter


func do_place_word_by_path(word: String, path: Array[Vector2]) -> void:
	for i in range(path.size()):
		var coord := path[i]
		var existing_cell := get_cell_at(coord)
		
		if existing_cell == null:
			var cell_instance = cell_template.instantiate()
			add_child(cell_instance)
			
			var pos_x = (coord.x - grid_width / 2.0 + 0.5) * cell_spacing
			var pos_y = (coord.y - grid_height / 2.0 + 0.5) * cell_spacing
			cell_instance.position = Vector2(pos_x, pos_y)
			
			cell_instance.set_letter(word[i], coord)
			cell_instance.set_hint()
			cells[coord] = cell_instance


func clear_grid() -> void:
	for child in get_children():
		child.queue_free()
	cells.clear()
	selected_cells.clear()


func get_cell_at(coord: Vector2) -> Node:
	return cells.get(coord)


func highlight_cell(coord: Vector2, highlight: bool) -> void:
	var cell = get_cell_at(coord)
	if cell:
		cell.set_highlighted(highlight)
		if highlight and not selected_cells.has(cell):
			selected_cells.append(cell)
		elif not highlight and selected_cells.has(cell):
			selected_cells.erase(cell)


func clear_highlights() -> void:
	for cell in selected_cells:
		cell.set_highlighted(false)
	selected_cells.clear()


func get_selected_letters() -> String:
	var result = ""
	for cell in selected_cells:
		result += cell.letter
	return result


func get_selected_coordinates() -> Array[Vector2]:
	var coords: Array[Vector2] = []
	for cell in selected_cells:
		coords.append(cell.coordinate)
	return coords


func mark_used(word_coords: Array) -> void:
	for coord in word_coords:
		var cell = get_cell_at(coord)
		if cell:
			cell.set_used()


func is_valid_coordinate(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.x < grid_width and coord.y >= 0 and coord.y < grid_height
