extends Node

var words: Array = []
var found_words: Array = []



func load_words() -> bool:
	var file := FileAccess.open("res://data/words.json", FileAccess.READ)
	if not file:
		print("ERROR: Failed to open words.json")
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json_result := JSON.new().parse(content)
	if json_result != OK:
		print("ERROR: Failed to parse JSON: ", JSON.new().get_error_message())
		return false
	
	var result := JSON.new().parse(content)
	if result != OK:
		print("ERROR: JSON parse failed: ", JSON.new().get_error_message())
		return false
	
	var data := JSON.new().parse(content)
	if data is Dictionary and data.has("words"):
		words = data["words"]
		print("WordManager: Loaded ", words.size(), " words")
		return true
	else:
		print("ERROR: Invalid JSON structure")
		return false

func is_valid_word(word: String) -> bool:
	var uppercase_word := word.to_upper()
	for w in words:
		if w == uppercase_word:
			return true
	return false

func mark_as_found(word: String) -> void:
	var uppercase_word := word.to_upper()
	if not uppercase_word in found_words:
		found_words.append(uppercase_word)
		print("WordManager: Found word: ", uppercase_word)

func get_remaining_words() -> Array:
	var remaining := []
	for w in words:
		if not w in found_words:
			remaining.append(w)
	return remaining

func reset() -> void:
	found_words = []
	print("WordManager: Reset found words")


