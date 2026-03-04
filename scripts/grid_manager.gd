extends Node2D

@export var word_manager: WordManager
@export var cell_template: PackedScene

const GRID_WIDTH: int = 4
const GRID_HEIGHT: int = 18
const CELL_SIZE: int = 60

var cells: Array[Array[Area2D]] = []
var grid_node: Node2D

signal cell_selected(coord: Vector2)

func _ready() -> void:
	randomize()
	grid_node = Node2D.new()
	grid_node.name = "GridNode"
	add_child(grid_node)
	generate_grid()

func generate_grid() -> void:
	for row in cells:
		for cell in row:
			if cell:
				(cell as Node).queue_free()
	
	cells.clear()
	
	for row in range(GRID_HEIGHT):
		var row_array: Array = []
		for col in range(GRID_WIDTH):
			var coord := Vector2(col, row)
			if cell_template == null:
				print("ERROR: cell_template is null")
				continue
			var cell := cell_template.instantiate() as Area2D
			cell.set_letter(get_random_letter(), coord)
			cell.connect("cell_selected", Callable(self, "_on_cell_selected").bind(coord))
			cell.position = coord * CELL_SIZE
			grid_node.add_child(cell)
			row_array.append(cell)
		cells.append(row_array)

func get_random_letter() -> String:
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	return letters[OS.rand() % letters.length()]

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
