class_name LevelManager 

extends Node

const MAX_LEVELS: int = 100

@export var word_manager: WordManager
@export var grid_manager: Node

var current_level: int = 1

signal level_completed


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
		return
	
	word_manager.on_level_complete()
	current_level += 1
	emit_signal("level_completed")