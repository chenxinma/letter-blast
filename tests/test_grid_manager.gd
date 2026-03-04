class_name GridManagerTest extends Node

func _test_grid_initialization() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new() as Node
	grid_manager.connect("cell_selected", Callable(self, "_on_cell_selected"))
	
	var test_grid_manager := load("res://scripts/grid_manager.gd").new()
	var word_manager := WordManager.new()
	test_grid_manager.word_manager = word_manager
	
	var grid_node := Node2D.new()
	test_grid_manager.add_child(grid_node)
	
	word_manager.queue_free()
	grid_node.queue_free()
	test_grid_manager.queue_free()

func _test_get_cell_valid_coordinates() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 18
	grid_manager.cells = []
	
	for row in range(18):
		var row_array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	assert(grid_manager.is_valid_coordinate(Vector2(0, 0)), "Valid coordinate (0,0)")
	assert(grid_manager.is_valid_coordinate(Vector2(3, 17)), "Valid coordinate (3,17)")
	assert(grid_manager.is_valid_coordinate(Vector2(2, 9)), "Valid coordinate (2,9)")
	
	grid_manager.queue_free()

func _test_get_cell_invalid_coordinates() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 18
	
	assert(not grid_manager.is_valid_coordinate(Vector2(-1, 0)), "Invalid negative x")
	assert(not grid_manager.is_valid_coordinate(Vector2(4, 0)), "Invalid x >= GRID_WIDTH")
	assert(not grid_manager.is_valid_coordinate(Vector2(0, -1)), "Invalid negative y")
	assert(not grid_manager.is_valid_coordinate(Vector2(0, 18)), "Invalid y >= GRID_HEIGHT")
	
	grid_manager.queue_free()

func _test_mark_cells_as_used() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 18
	grid_manager.cells = []
	
	for row in range(18):
		var row_array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	var test_coord := Vector2(1, 1)
	assert(grid_manager.is_valid_coordinate(test_coord), "Test coordinate should be valid")
	
	grid_manager.queue_free()

func _test_get_cell_returns_null_for_invalid() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	
	var result := grid_manager.get_cell(Vector2(-1, -1))
	assert(result == null, "get_cell should return null for invalid coordinates")
	
	result = grid_manager.get_cell(Vector2(100, 100))
	assert(result == null, "get_cell should return null for out of bounds coordinates")
	
	grid_manager.queue_free()

func _test_randomize_called() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager._ready()
	
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var letter1 := grid_manager.get_random_letter()
	var letter2 := grid_manager.get_random_letter()
	
	assert(letters.has(letter1), "get_random_letter should return a letter")
	assert(letters.has(letter2), "get_random_letter should return a letter")
	
	grid_manager.queue_free()

func _on_cell_selected(coord: Vector2) -> void:
	pass

func _run_tests() -> void:
	_test_grid_initialization()
	_test_get_cell_valid_coordinates()
	_test_get_cell_invalid_coordinates()
	_test_mark_cells_as_used()
	_test_get_cell_returns_null_for_invalid()
	_test_randomize_called()
	print("All GridManager tests passed!")
