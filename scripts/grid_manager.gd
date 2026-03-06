class_name GridManager

extends Node2D

@export var word_manager: WordManager
@export var cell_template: PackedScene
@export var words_per_level: int = 5

const GRID_WIDTH: int = 4
const GRID_HEIGHT: int = 18
const CELL_SIZE: int = 60
const MAX_PLACEMENT_ATTEMPTS: int = 100

var cells = []
var grid_node: Node2D

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
	# Generate grid after word_manager is assigned
	call_deferred("generate_grid")

func generate_grid() -> void:
	for row in cells:
		for cell in row:
			if cell:
				(cell as Node).queue_free()
	
	cells.clear()
	
	for row in range(GRID_HEIGHT):
		var row_array: Array[Area2D] = []
		for col in range(GRID_WIDTH):
			row_array.append(null)
		cells.append(row_array)
	
	var placed_words: Array = []
	
	for word in word_manager.words:
		if placed_words.size() >= words_per_level:
			break
		
		if place_word_in_grid(word):
			placed_words.append(word)
	
	for row in range(GRID_HEIGHT):
		for col in range(GRID_WIDTH):
			if cells[row][col] == null:
				var coord := Vector2(col, row)
				if cell_template == null:
					print("ERROR: cell_template is null")
					continue
				var cell := cell_template.instantiate() as Area2D
				cell.position = coord * CELL_SIZE
				grid_node.add_child(cell)
				cell.set_letter(get_random_letter(), coord)
				cell.connect("cell_selected", Callable(self, "_on_cell_selected").bind(coord))
				cells[row][col] = cell

func get_random_letter() -> String:
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	return letters[randi() % letters.length()]

func place_word_in_grid(word: String) -> bool:
	for _i in range(MAX_PLACEMENT_ATTEMPTS):
		var direction_idx := randi() % DIRECTIONS.size()
		var direction := DIRECTIONS[direction_idx]
		
		var start_x := randi() % GRID_WIDTH
		var start_y := randi() % GRID_HEIGHT
		
		if can_place_word(word, start_x, start_y, direction):
			do_place_word(word, start_x, start_y, direction)
			return true
	
	return false

func can_place_word(word: String, start_x: int, start_y: int, direction: Vector2) -> bool:
	var x := start_x
	var y := start_y
	
	for i in range(word.length()):
		if not is_valid_coordinate(Vector2(x, y)):
			return false
		
		var coord := Vector2(x, y)
		var cell := get_cell(coord)
		if cell != null:
			if cell.is_used:
				if cell.letter != word[i]:
					return false
		
		x += direction.x
		y += direction.y
	
	return true

func do_place_word(word: String, start_x: int, start_y: int, direction: Vector2) -> void:
	var x := start_x
	var y := start_y
	
	for i in range(word.length()):
		var coord := Vector2(x, y)
		var cell := get_cell(coord)
		if cell != null:
			cell.set_letter(word[i], coord)
			cell.set_used(true)
		x += direction.x
		y += direction.y

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
