extends Node

const MAX_LEVELS: int = 100

@export var word_manager: WordManager
@export var grid_manager: GridManager

var current_level: int = 1
var _level_complete_pending: bool = false

func _ready() -> void:
	if not word_manager:
		print("ERROR: word_manager is not assigned")
		return
	if not grid_manager:
		print("ERROR: grid_manager is not assigned")
		return


func start_level() -> void:
	if not word_manager or not grid_manager:
		print("ERROR: Required managers not assigned")
		return
	word_manager.reset()
	grid_manager.generate_grid()
	print("LevelManager: Starting Level ", current_level)


func check_level_complete() -> void:
	if not word_manager:
		return
	var remaining := word_manager.get_remaining_words()
	if remaining.size() == 0:
		level_complete()


func level_complete() -> void:
	print("LevelManager: Level ", current_level, " Complete!")
	if current_level >= MAX_LEVELS:
		print("LevelManager: Game Complete - Max level reached!")
		emit_signal("game_complete")
		return
	current_level += 1
	start_level()
