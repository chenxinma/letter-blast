extends Node

var custom_words: Dictionary = {}
var custom_word_meanings: Dictionary = {}
var has_custom_words: bool = false


func set_custom_words(words: Dictionary, meanings: Dictionary) -> void:
	custom_words = words
	custom_word_meanings = meanings
	has_custom_words = true
	print("GlobalWordManager: Custom words set, count: ", words.size())


func get_words() -> Dictionary:
	if has_custom_words:
		return custom_words
	return {}


func get_word_meanings() -> Dictionary:
	if has_custom_words:
		return custom_word_meanings
	return {}


func clear_custom_words() -> void:
	custom_words.clear()
	custom_word_meanings.clear()
	has_custom_words = false