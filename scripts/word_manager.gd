class_name WordManager

extends Node

var words: Dictionary = {}
var found_words: Dictionary = {}
var level_manager: Node

func _ready() -> void:
	level_manager = get_node_or_null("../LevelManager")


func load_words() -> bool:
	var file := FileAccess.open("res://data/words.json", FileAccess.READ)
	if not file:
		print("ERROR: Failed to open words.json")
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary and data.has("words") and data["words"] is Array:
			for word in data["words"]:
				if word is String:
					words[word.to_upper()] = true
			print("WordManager: Loaded ", words.size(), " words")
			return true
		return false
	else:
		print("ERROR: JSON parse failed: ", json.get_error_message())
		return false

func is_valid_word(word: String) -> bool:
	return words.has(word.to_upper())

func mark_as_found(word: String) -> void:
	var uppercase_word := word.to_upper()
	if not found_words.has(uppercase_word):
		found_words[uppercase_word] = true
		print("WordManager: Found word: ", uppercase_word)
		if level_manager and level_manager.has_method("check_level_complete"):
			level_manager.check_level_complete()

func get_remaining_words() -> Array:
	var remaining := []
	for word_key in words:
		if not found_words.has(word_key):
			remaining.append(word_key)
	return remaining

func get_found_words() -> Array:
	var found := []
	for word_key in found_words:
		found.append(word_key)
	return found

func reset() -> void:
	found_words.clear()
	print("WordManager: Reset found words")
