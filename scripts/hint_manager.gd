class_name HintManager

extends Node

const MAX_HINTS_PER_LEVEL: int = 3

var hints_left: int = MAX_HINTS_PER_LEVEL
var current_level: int = 1
var remaining_words: Array = []
var found_words: Array = []

signal hint_used(hint_type: String, word: String)


func _ready() -> void:
	pass


func set_level(level_num: int) -> void:
	current_level = level_num
	hints_left = MAX_HINTS_PER_LEVEL


func reset_level() -> void:
	hints_left = MAX_HINTS_PER_LEVEL
	remaining_words.clear()
	found_words.clear()


func set_remaining_words(words: Array) -> void:
	remaining_words = words


func set_found_words(words: Array) -> void:
	found_words = words


func use_hint() -> Dictionary:
	if hints_left <= 0 or remaining_words.is_empty():
		return {"success": false, "message": "No hints left"}
	
	hints_left -= 1
	
	var word = remaining_words[0]
	var word_upper = word.to_upper()
	
	emit_signal("hint_used", "reveal_word", word_upper)
	
	return {
		"success": true,
		"word": word_upper,
		"hints_left": hints_left
	}


func use_letter_hint() -> Dictionary:
	if hints_left <= 0 or remaining_words.is_empty():
		return {"success": false, "message": "No hints left"}
	
	hints_left -= 1
	
	var word = remaining_words[0]
	var word_upper = word.to_upper()
	
	if word_upper.length() > 0:
		var first_letter = word_upper[0]
		return {
			"success": true,
			"letter": first_letter,
			"word": word_upper,
			"hints_left": hints_left
		}
	
	return {"success": false, "message": "Invalid word"}


func get_hints_left() -> int:
	return hints_left


func can_use_hint() -> bool:
	return hints_left > 0 and not remaining_words.is_empty()
