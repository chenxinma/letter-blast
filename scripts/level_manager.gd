class_name LevelManager 

extends Node

const MAX_LEVELS: int = 100

@export var word_manager: WordManager
@export var grid_manager: GridManager

var current_level: int = 1
var assigned_words: Array = []

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
	current_level += 1
	emit_signal("level_completed")


func get_level_word_count() -> int:
	var word_count = 5
	if current_level >= 1 and current_level <= 3:
		word_count = 3
	elif current_level >= 4 and current_level <= 6:
		word_count = 5
	elif current_level >= 7 and current_level <= 10:
		word_count = 6
	else:
		word_count = 8
	return word_count


func assign_words() -> void:
	var word_limit = get_level_word_count()
	var remaining := word_manager.get_remaining_words()
	assigned_words.clear()
	
	for word in remaining:
		if assigned_words.size() >= word_limit:
			break
		assigned_words.append(word)
