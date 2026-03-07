class_name GridManager

extends Node2D

@export var word_manager: WordManager
@export var cell_template: PackedScene

const GRID_WIDTH: int = 18
const GRID_HEIGHT: int = 4
const CELL_SIZE: int = 60
const MAX_PLACEMENT_ATTEMPTS: int = 100
const MAX_RECURSION_DEPTH: int = 30

var cells = []
var grid_node: Node2D
var placed_paths: Dictionary = {}

signal cell_selected(coord: Vector2)

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

func _ready() -> void:
	randomize()
	if grid_node:
		grid_node.queue_free()
	grid_node = Node2D.new()
	grid_node.name = "GridNode"
	add_child(grid_node)

func generate_grid() -> void:
	for row in cells:
		for cell in row:
			if cell:
				(cell as Node).queue_free()
	
	cells.clear()
	placed_paths.clear()
	
	for row in range(GRID_HEIGHT):
		var row_array: Array[Area2D] = []
		for col in range(GRID_WIDTH):
			row_array.append(null)
		cells.append(row_array)
	
	var assigned_words: Array = []
	if word_manager.has_method("get_assigned_words"):
		assigned_words = word_manager.get_assigned_words()
	
	if cell_template == null:
		print("ERROR: cell_template is null")
		return
	
	for word in assigned_words:
		place_word_in_grid(word)
	
	for row in range(GRID_HEIGHT):
		for col in range(GRID_WIDTH):
			if cells[row][col] == null:
				var coord := Vector2(col, row)
				var cell := cell_template.instantiate() as Area2D
				cell.position = coord * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
				grid_node.add_child(cell)
				cell.set_letter(get_random_letter(), coord)
				cells[row][col] = cell

func get_random_letter() -> String:
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	return letters[randi() % letters.length()]

func place_word_in_grid(word: String) -> bool:
	if word.is_empty():
		return false
	
	for _i in range(MAX_PLACEMENT_ATTEMPTS):
		var start_x := randi() % GRID_WIDTH
		var start_y := randi() % GRID_HEIGHT
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
	
	var cell := get_cell(coord)
	
	if cell == null:
		return true
	
	if cell.is_used:
		return false
	
	return cell.letter == letter

func do_place_word_by_path(word: String, path: Array[Vector2]) -> void:
	for i in range(path.size()):
		var coord := path[i]
		var existing_cell := get_cell(coord)
		
		if existing_cell == null:
			var cell := cell_template.instantiate() as Area2D
			cell.position = coord * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
			grid_node.add_child(cell)
			cell.set_letter(word[i], coord)
			cell.set_hint()
			cells[coord.y][coord.x] = cell

func mark_cells_as_used(coordinates: Array) -> void:
	for coord in coordinates:
		var cell := get_cell(coord)
		if cell != null:
			cell.set_used(true)

func is_valid_coordinate(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.x < GRID_WIDTH and coord.y >= 0 and coord.y < GRID_HEIGHT

func get_cell(coord: Vector2) -> Area2D:
	if is_valid_coordinate(coord):
		return cells[coord.y][coord.x]
	return null

func _on_cell_selected(coord: Vector2) -> void:
	cell_selected.emit(coord)
