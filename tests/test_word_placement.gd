class_name GridManagerTest extends Node

func _test_word_placement() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 4
	grid_manager.cells = []
	
	for row in range(4):
		var row_array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	var word_manager := WordManager.new()
	word_manager.words = ["CAT", "DOG"]
	grid_manager.word_manager = word_manager
	
	grid_manager.place_word_in_grid("CAT")
	var placed := grid_manager.place_word_in_grid("DOG")
	
	assert(placed, "Word DOG should be placed")
	
	grid_manager.queue_free()
	word_manager.queue_free()

func _test_overlap_validation() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 4
	grid_manager.cells = []
	
	for row in range(4):
		var row_array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	grid_manager.do_place_word("CAT", 0, 0, Vector2(1, 0))
	
	var valid := grid_manager.can_place_word("CAR", 0, 0, Vector2(1, 0))
	assert(not valid, "Overlapping word with different letter should be invalid")
	
	grid_manager.queue_free()

func _test_get_cell_returns_null_for_invalid() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 4
	
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

func _test_grid_initialization() -> void:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	
	var word_manager := WordManager.new()
	word_manager.words = ["TEST"]
	grid_manager.word_manager = word_manager
	
	var grid_node := Node2D.new()
	grid_manager.add_child(grid_node)
	
	word_manager.queue_free()
	grid_node.queue_free()
	grid_manager.queue_free()

func _run_tests() -> void:
	_test_word_placement()
	_test_overlap_validation()
	_test_get_cell_returns_null_for_invalid()
	_test_randomize_called()
	_test_grid_initialization()
	print("All GridManager tests passed!")
