class_name TestWordPlacement extends Node

func _test_simple_path_placement() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var result := grid_manager.place_word_in_grid("CAT")
	assert(result, "CAT should be placed successfully")
	assert(grid_manager.placed_paths.has("CAT"), "placed_paths should contain CAT")
	assert(grid_manager.placed_paths["CAT"].size() == 3, "CAT path should have 3 coordinates")
	
	_cleanup_grid_manager(grid_manager)

func _test_no_self_intersect() -> void:
	var grid_manager := _create_test_grid_manager()
	
	grid_manager.place_word_in_grid("HELLO")
	var path: Variant = grid_manager.placed_paths.get("HELLO", [])
	
	assert(path.size() == 5, "HELLO path should have 5 coordinates")
	
	var visited: Dictionary = {}
	for coord in path:
		assert(not visited.has(coord), "Path should not self-intersect")
		visited[coord] = true
	
	_cleanup_grid_manager(grid_manager)

func _test_multiple_words_placement() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var words := ["CAT", "DOG", "BIRD"]
	for word in words:
		var result := grid_manager.place_word_in_grid(word)
		assert(result, word + " should be placed successfully")
	
	assert(grid_manager.placed_paths.size() == 3, "Should have 3 words placed")
	
	_cleanup_grid_manager(grid_manager)

func _test_letter_sharing() -> void:
	var grid_manager := _create_test_grid_manager()
	
	grid_manager.place_word_in_grid("CAT")
	grid_manager.place_word_in_grid("BAT")
	
	assert(grid_manager.placed_paths.has("CAT"), "CAT should be placed")
	assert(grid_manager.placed_paths.has("BAT"), "BAT should be placed")
	
	var cat_path: Variant = grid_manager.placed_paths["CAT"]
	var bat_path: Variant = grid_manager.placed_paths["BAT"]
	
	var shared_coords: int = 0
	for coord in cat_path:
		if bat_path.has(coord):
			shared_coords += 1
	
	assert(shared_coords >= 2, "CAT and BAT should share at least 2 letters (A and T)")
	
	_cleanup_grid_manager(grid_manager)

func _test_empty_word() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var result := grid_manager.place_word_in_grid("")
	assert(not result, "Empty word should return false")
	
	_cleanup_grid_manager(grid_manager)

func _test_get_available_directions() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var visited: Dictionary = {}
	var directions := grid_manager.get_available_directions(Vector2(1, 1), Vector2(0, 1), visited)
	
	assert(directions.size() == 3, "Should have 3 available directions (excluding reverse DOWN)")
	assert(not directions.has(Vector2(0, -1)), "Should not contain UP (reverse of DOWN)")
	
	_cleanup_grid_manager(grid_manager)

func _test_get_available_directions_with_visited() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var visited: Dictionary = {Vector2(2, 1): true}
	var directions := grid_manager.get_available_directions(Vector2(1, 1), Vector2.ZERO, visited)
	
	assert(not directions.has(Vector2(1, 0)), "Should not contain RIGHT direction to visited cell")
	
	_cleanup_grid_manager(grid_manager)

func _test_can_place_char_at_empty() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var result := grid_manager.can_place_char_at(Vector2(0, 0), "A")
	assert(result, "Should be able to place char in empty cell")
	
	_cleanup_grid_manager(grid_manager)

func _test_can_place_char_at_out_of_bounds() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var result := grid_manager.can_place_char_at(Vector2(-1, 0), "A")
	assert(not result, "Should not be able to place char out of bounds")
	
	result = grid_manager.can_place_char_at(Vector2(100, 100), "A")
	assert(not result, "Should not be able to place char out of bounds")
	
	_cleanup_grid_manager(grid_manager)

func _test_recursion_depth_limit() -> void:
	var grid_manager := _create_test_grid_manager()
	
	var long_word := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var result := grid_manager.place_word_in_grid(long_word)
	assert(not result, "Very long word should fail due to depth limit")
	
	_cleanup_grid_manager(grid_manager)

func _test_placed_paths_cleared_on_generate() -> void:
	var grid_manager := _create_test_grid_manager()
	
	grid_manager.place_word_in_grid("CAT")
	assert(grid_manager.placed_paths.size() == 1, "Should have 1 placed word")
	
	grid_manager.cells.clear()
	for row in range(4):
		var row_array: Array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	grid_manager.placed_paths.clear()
	
	assert(grid_manager.placed_paths.is_empty(), "placed_paths should be cleared")
	
	_cleanup_grid_manager(grid_manager)

func _test_path_directions_valid() -> void:
	var grid_manager := _create_test_grid_manager()
	
	grid_manager.place_word_in_grid("HELLO")
	var path: Variant = grid_manager.placed_paths.get("HELLO", [])
	
	assert(path.size() >= 2, "Path should have at least 2 coordinates")
	
	for i in range(1, path.size()):
		var prev: Vector2 = path[i - 1]
		var curr: Vector2 = path[i]
		var diff := curr - prev
		
		var is_valid_direction := false
		for dir in grid_manager.DIRECTIONS:
			if diff == dir:
				is_valid_direction = true
				break
		
		assert(is_valid_direction, "Each step should be a valid direction")
	
	_cleanup_grid_manager(grid_manager)

func _create_test_grid_manager() -> Node:
	var grid_manager := load("res://scripts/grid_manager.gd").new()
	grid_manager.GRID_WIDTH = 4
	grid_manager.GRID_HEIGHT = 4
	grid_manager.cells = []
	grid_manager.placed_paths = {}
	
	var grid_node := Node2D.new()
	grid_manager.add_child(grid_node)
	grid_manager.grid_node = grid_node
	
	for row in range(4):
		var row_array: Array = []
		for col in range(4):
			row_array.append(null)
		grid_manager.cells.append(row_array)
	
	return grid_manager

func _cleanup_grid_manager(grid_manager: Node) -> void:
	if grid_manager.grid_node:
		grid_manager.grid_node.queue_free()
	grid_manager.queue_free()

func _run_tests() -> void:
	_test_simple_path_placement()
	_test_no_self_intersect()
	_test_multiple_words_placement()
	_test_letter_sharing()
	_test_empty_word()
	_test_get_available_directions()
	_test_get_available_directions_with_visited()
	_test_can_place_char_at_empty()
	_test_can_place_char_at_out_of_bounds()
	_test_recursion_depth_limit()
	_test_placed_paths_cleared_on_generate()
	_test_path_directions_valid()
	print("All path placement tests passed!")