extends Node

@export var word_manager: WordManager
@export var grid_manager: GridManager

var words_per_level: int = 5
var current_level: int = 1


func start_level() -> void:
	word_manager.reset()
	grid_manager.generate_grid()
	print("LevelManager: Starting Level ", current_level)


func check_level_complete() -> void:
	var remaining := word_manager.get_remaining_words()
	if remaining.size() == 0:
		level_complete()


func level_complete() -> void:
	print("LevelManager: Level ", current_level, " Complete!")
	current_level += 1
	start_level()
