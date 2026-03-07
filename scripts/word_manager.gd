class_name WordManager

extends Node

const SAVE_FILE = "user://word_progress.json"
const NUM_BOXES = 5

var words: Dictionary = {}
var word_meanings: Dictionary = {}
var word_boxes: Dictionary = {}
var found_words: Dictionary = {}
var level_words: Array = []

var level_manager: Node

signal progress_saved


func _ready() -> void:
	level_manager = get_node_or_null("../LevelManager")
	load_words()
	load_progress()


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
			for word_entry in data["words"]:
				if word_entry is Dictionary and word_entry.has("en"):
					var upper_word = word_entry["en"].to_upper()
					words[upper_word] = true
					if word_entry.has("zh"):
						word_meanings[upper_word] = word_entry["zh"]
					if not word_boxes.has(upper_word):
						word_boxes[upper_word] = 1
			print("WordManager: Loaded ", words.size(), " words")
			return true
		return false
	else:
		print("ERROR: JSON parse failed: ", json.get_error_message())
		return false


func get_level_words(word_count: int) -> Array:
	level_words.clear()
	
	for box_num in range(1, NUM_BOXES + 1):
		var box_words = get_words_in_box(box_num)
		if box_words.size() > 0:
			box_words.shuffle()
			for i in range(min(word_count - level_words.size(), box_words.size())):
				level_words.append(box_words[i])
			if level_words.size() >= word_count:
				break
	
	return level_words


func get_words_in_box(box_num: int) -> Array:
	var result := []
	for word in word_boxes:
		if word_boxes[word] == box_num:
			result.append(word)
	return result


func get_first_non_empty_box() -> int:
	for box_num in range(1, NUM_BOXES + 1):
		if get_words_in_box(box_num).size() > 0:
			return box_num
	return 0


func is_valid_word(word: String) -> bool:
	return words.has(word.to_upper())


func get_chinese(word: String) -> String:
	var upper_word = word.to_upper()
	return word_meanings.get(upper_word, "")


func get_level_words_info() -> Array:
	var result := []
	for word in level_words:
		result.append({
			"en": word,
			"zh": word_meanings.get(word, "")
		})
	return result


func mark_as_found(word: String) -> void:
	var uppercase_word := word.to_upper()
	if not found_words.has(uppercase_word):
		found_words[uppercase_word] = true
		print("WordManager: Found word: ", uppercase_word)
		if level_manager and level_manager.has_method("check_level_complete"):
			level_manager.check_level_complete()


func is_word_found(word: String) -> bool:
	return found_words.has(word.to_upper())


func is_level_word(word: String) -> bool:
	return level_words.has(word.to_upper())


func on_level_complete() -> void:
	for word in level_words:
		if found_words.has(word):
			promote_word(word)
		else:
			demote_word(word)
	
	found_words.clear()
	level_words.clear()
	save_progress()


func promote_word(word: String) -> void:
	var current_box = word_boxes.get(word, 1)
	if current_box < NUM_BOXES:
		word_boxes[word] = current_box + 1
		print("WordManager: Promoted '", word, "' to box ", word_boxes[word])


func demote_word(word: String) -> void:
	var current_box = word_boxes.get(word, 1)
	if current_box > 1:
		word_boxes[word] = current_box - 1
		print("WordManager: Demoted '", word, "' to box ", word_boxes[word])


func get_remaining_words() -> Array:
	var remaining := []
	for word in level_words:
		if not found_words.has(word):
			remaining.append(word)
	return remaining


func get_found_words() -> Array:
	var found := []
	for word_key in found_words:
		found.append(word_key)
	return found


func reset_level() -> void:
	found_words.clear()


func get_box_stats() -> Dictionary:
	var stats := {}
	for i in range(1, NUM_BOXES + 1):
		stats[i] = get_words_in_box(i).size()
	return stats


func load_progress() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		print("WordManager: No save data found, using defaults")
		return
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary and data.has("word_boxes"):
			word_boxes = data["word_boxes"]
			print("WordManager: Progress loaded")


func save_progress() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if not file:
		print("ERROR: Failed to save progress")
		return
	
	var json_str = JSON.stringify({
		"word_boxes": word_boxes
	})
	
	file.store_string(json_str)
	file.close()
	print("WordManager: Progress saved")
	progress_saved.emit()
