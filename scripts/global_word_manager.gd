extends Node

const SAVE_FILE = "user://learning_progress.json"

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


func import_words_to_progress(json_content: String) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(json_content)
	if error != OK:
		print("GlobalWordManager: ERROR - JSON parse failed")
		return {"success": false, "error": "JSON格式错误"}
	
	var data = json.data
	if not (data is Dictionary and data.has("words") and data["words"] is Array):
		return {"success": false, "error": "无效的单词表格式"}
	
	var new_words = data["words"]
	var current_data = _load_progress_data()
	var existing_words = {}
	
	if current_data.has("words") and current_data["words"] is Array:
		for word_entry in current_data["words"]:
			if word_entry is Dictionary and word_entry.has("en"):
				existing_words[word_entry["en"].to_upper()] = true
	
	var added_count = 0
	var skipped_count = 0
	
	for word_entry in new_words:
		if word_entry is Dictionary and word_entry.has("en"):
			var upper_word = word_entry["en"].to_upper()
			if not existing_words.has(upper_word):
				if not current_data.has("words"):
					current_data["words"] = []
				current_data["words"].append(word_entry)
				existing_words[upper_word] = true
				added_count += 1
			else:
				skipped_count += 1
	
	_save_progress_data(current_data)
	print("GlobalWordManager: Imported ", added_count, " new words, skipped ", skipped_count)
	
	return {
		"success": true,
		"added": added_count,
		"skipped": skipped_count,
		"total": existing_words.size()
	}


func import_words_from_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("GlobalWordManager: ERROR - Failed to open file: ", path)
		return {"success": false, "error": "无法打开文件"}
	
	var content := file.get_as_text()
	file.close()
	
	return import_words_to_progress(content)


func _load_progress_data() -> Dictionary:
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		return {
			"version": "1.1",
			"last_updated": "",
			"words": [],
			"boxes": {
				"box1": [],
				"box2": [],
				"box3": [],
				"box4": [],
				"box5": []
			},
			"statistics": {
				"total_games_played": 0,
				"total_score": 0,
				"words_mastered": 0
			}
		}
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.data
	return {}


func _save_progress_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if not file:
		print("GlobalWordManager: ERROR - Failed to save progress")
		return
	
	data["last_updated"] = Time.get_datetime_string_from_system()
	if not data.has("version"):
		data["version"] = "1.1"
	
	var json_str = JSON.stringify(data, "  ")
	file.store_string(json_str)
	file.close()
	print("GlobalWordManager: Progress saved")
