extends Node

var words: Dictionary = {}
var found_words: Dictionary = {}


func load_words() -> bool:
	var file := FileAccess.open("res://data/words.json", FileAccess.READ)
	if not file:
		print("ERROR: Failed to open words.json")
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var data := json.parse(content)
	if data is Dictionary and data.has("words"):
		for word in data["words"]:
			words[word.to_upper()] = true
		print("WordManager: Loaded ", words.size(), " words")
		return true
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

func get_remaining_words() -> Array:
	var remaining := []
	for word_key in words:
		if not found_words.has(word_key):
			remaining.append(word_key)
	return remaining

func reset() -> void:
	found_words.clear()
	print("WordManager: Reset found words")


