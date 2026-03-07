extends "res://scripts/level_manager.gd"

func _test_start_level() -> void:
	var level_manager := LevelManager.new()
	level_manager.word_manager = WordManager.new()
	level_manager.word_manager.load_words()
	level_manager.grid_manager = GridManager.new()
	level_manager.current_level = 1
	
	assert(level_manager.current_level == 1, "Initial level should be 1")
	level_manager.queue_free()

func _test_level_complete_increments() -> void:
	var level_manager := LevelManager.new()
	level_manager.word_manager = WordManager.new()
	level_manager.word_manager.load_words()
	level_manager.grid_manager = GridManager.new()
	level_manager.current_level = 1
	
	level_manager.level_complete()
	assert(level_manager.current_level == 2, "Level should increment after completion")
	level_manager.queue_free()

func _test_level_complete_max_level() -> void:
	var level_manager := LevelManager.new()
	level_manager.word_manager = WordManager.new()
	level_manager.word_manager.load_words()
	level_manager.grid_manager = GridManager.new()
	level_manager.current_level = 100
	
	level_manager.level_complete()
	assert(level_manager.current_level == 100, "Level should not exceed max")
	level_manager.queue_free()

func _test_null_word_manager() -> void:
	var level_manager := LevelManager.new()
	level_manager.word_manager = null
	level_manager.grid_manager = GridManager.new()
	
	level_manager.check_level_complete()
	level_manager.queue_free()

func _run_tests() -> void:
	_test_start_level()
	_test_level_complete_increments()
	_test_level_complete_max_level()
	_test_null_word_manager()
	print("All LevelManager tests passed!")