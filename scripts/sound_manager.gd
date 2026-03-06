class_name SoundManager

extends Node

signal word_found(word: String)
signal cell_selected
signal invalid_word
signal level_complete

func play_sound(sound_name: String) -> void:
	match sound_name:
		"cell_select":
			cell_selected.emit()
		"word_found":
			word_found.emit()
		"invalid_word":
			invalid_word.emit()
		"level_complete":
			level_complete.emit()
