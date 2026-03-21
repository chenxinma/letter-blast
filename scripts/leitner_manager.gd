extends Node

const SAVE_FILE = "user://learning_progress.json"
const DEFAULT_WORDS_FILE = "res://data/words.json"
const NUM_BOXES = 5
const BOX_INTERVALS = [1, 2, 4, 7, 14]
const WORDS_PER_GAME = 4

var words: Dictionary = {}
var word_meanings: Dictionary = {}
var words_list: Array = []
var boxes: Dictionary = {
	"box1": [],
	"box2": [],
	"box3": [],
	"box4": [],
	"box5": []
}
var current_game_words: Array = []
var found_words: Dictionary = {}
var total_games_played: int = 0
var total_score: int = 0
var words_mastered: int = 0

signal progress_saved
signal game_completed(words_found: Array, words_missed: Array)


func _ready() -> void:
	load_progress()
	if words.is_empty():
		load_default_words()


func load_default_words() -> bool:
	var file := FileAccess.open(DEFAULT_WORDS_FILE, FileAccess.READ)
	if not file:
		print("LeitnerManager: ERROR - Failed to open default words.json")
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary and data.has("words"):
			words_list = data["words"]
			_parse_words_list()
			print("LeitnerManager: Loaded ", words.size(), " default words")
			return true
	return false


func _parse_words_list() -> void:
	words.clear()
	word_meanings.clear()
	for word_entry in words_list:
		if word_entry is Dictionary and word_entry.has("en"):
			var upper_word = word_entry["en"].to_upper()
			words[upper_word] = true
			if word_entry.has("zh"):
				word_meanings[upper_word] = word_entry["zh"]


func get_words_for_game() -> Array:
	var selected_words = []
	
	for box_num in range(1, NUM_BOXES + 1):
		var box_key = "box" + str(box_num)
		var box_words = boxes[box_key]
		var interval = BOX_INTERVALS[box_num - 1]
		
		for word_data in box_words:
			if selected_words.size() >= WORDS_PER_GAME:
				break
			if _days_since(word_data.last_reviewed) >= interval:
				selected_words.append(word_data.word)
		
		if selected_words.size() >= WORDS_PER_GAME:
			break
	
	if selected_words.size() < WORDS_PER_GAME:
		var available_new_words = []
		for word in words:
			if not _is_word_in_any_box(word):
				available_new_words.append(word)
		
		available_new_words.shuffle()
		
		for word in available_new_words:
			if selected_words.size() >= WORDS_PER_GAME:
				break
			selected_words.append(word)
	
	current_game_words = selected_words.duplicate()
	found_words.clear()
	
	return selected_words


func _is_word_in_any_box(word: String) -> bool:
	for box_num in range(1, NUM_BOXES + 1):
		var box_key = "box" + str(box_num)
		for word_data in boxes[box_key]:
			if word_data.word == word:
				return true
	return false


func _days_since(date_str: String) -> int:
	if date_str.is_empty():
		return 999
	
	var current_time = Time.get_datetime_string_from_system()
	var current_date = current_time.split("T")[0]
	var target_date = date_str.split("T")[0]
	
	var current_parts = current_date.split("-")
	var target_parts = target_date.split("-")
	
	if current_parts.size() < 3 or target_parts.size() < 3:
		return 999
	
	var current_days = int(current_parts[0]) * 365 + int(current_parts[1]) * 30 + int(current_parts[2])
	var target_days = int(target_parts[0]) * 365 + int(target_parts[1]) * 30 + int(target_parts[2])
	
	return current_days - target_days


func get_current_game_words_info() -> Array:
	var result := []
	for word in current_game_words:
		result.append({
			"en": word,
			"zh": word_meanings.get(word, "")
		})
	return result


func is_valid_word(word: String) -> bool:
	return words.has(word.to_upper())


func is_game_word(word: String) -> bool:
	return current_game_words.has(word.to_upper())


func mark_word_found(word: String) -> void:
	var upper_word = word.to_upper()
	if not found_words.has(upper_word):
		found_words[upper_word] = true
		print("LeitnerManager: Found word: ", upper_word)


func is_word_found(word: String) -> bool:
	return found_words.has(word.to_upper())


func get_found_words() -> Array:
	return found_words.keys()


func get_remaining_words() -> Array:
	var remaining := []
	for word in current_game_words:
		if not found_words.has(word):
			remaining.append(word)
	return remaining


func get_chinese(word: String) -> String:
	return word_meanings.get(word.to_upper(), "")


func is_game_complete() -> bool:
	return get_remaining_words().size() == 0


func on_game_complete() -> void:
	var words_found = []
	var words_missed = []
	
	for word in current_game_words:
		if found_words.has(word):
			words_found.append(word)
			_promote_word(word)
		else:
			words_missed.append(word)
			_demote_word(word)
	
	total_games_played += 1
	
	var mastered_count = 0
	for word_data in boxes["box5"]:
		mastered_count += 1
	words_mastered = mastered_count
	
	save_progress()
	emit_signal("game_completed", words_found, words_missed)
	
	found_words.clear()
	current_game_words.clear()


func _promote_word(word: String) -> void:
	var current_box = _find_word_box(word)
	
	if current_box == 0:
		_add_word_to_box(word, 1)
		return
	
	if current_box < NUM_BOXES:
		_remove_word_from_box(word, current_box)
		_add_word_to_box(word, current_box + 1)
		print("LeitnerManager: Promoted '", word, "' to box ", current_box + 1)


func _demote_word(word: String) -> void:
	var current_box = _find_word_box(word)
	
	if current_box == 0:
		_add_word_to_box(word, 1)
		return
	
	if current_box > 1:
		_remove_word_from_box(word, current_box)
		_add_word_to_box(word, 1)
		print("LeitnerManager: Demoted '", word, "' to box 1")


func _find_word_box(word: String) -> int:
	for box_num in range(1, NUM_BOXES + 1):
		var box_key = "box" + str(box_num)
		for word_data in boxes[box_key]:
			if word_data.word == word:
				return box_num
	return 0


func _add_word_to_box(word: String, box_num: int) -> void:
	var box_key = "box" + str(box_num)
	var current_time = Time.get_datetime_string_from_system()
	
	var existing_data = _get_word_data(word)
	if existing_data:
		existing_data["last_reviewed"] = current_time
		existing_data["review_count"] = existing_data.get("review_count", 0) + 1
		boxes[box_key].append(existing_data)
	else:
		boxes[box_key].append({
			"word": word,
			"first_learned": current_time,
			"last_reviewed": current_time,
			"review_count": 1,
			"success_count": 1,
			"fail_count": 0
		})


func _remove_word_from_box(word: String, box_num: int) -> void:
	var box_key = "box" + str(box_num)
	var new_box = []
	for word_data in boxes[box_key]:
		if word_data.word != word:
			new_box.append(word_data)
	boxes[box_key] = new_box


func _get_word_data(word: String) -> Dictionary:
	for box_num in range(1, NUM_BOXES + 1):
		var box_key = "box" + str(box_num)
		for word_data in boxes[box_key]:
			if word_data.word == word:
				return word_data
	return {}


func update_score(score: int) -> void:
	total_score += score


func get_box_stats() -> Dictionary:
	var stats := {}
	for i in range(1, NUM_BOXES + 1):
		stats[i] = boxes["box" + str(i)].size()
	return stats


func get_statistics() -> Dictionary:
	return {
		"total_games_played": total_games_played,
		"total_score": total_score,
		"words_mastered": words_mastered,
		"total_words_learned": _get_total_words_learned()
	}


func _get_total_words_learned() -> int:
	var count = 0
	for box_num in range(1, NUM_BOXES + 1):
		count += boxes["box" + str(box_num)].size()
	return count


func load_progress() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		print("LeitnerManager: No save data found, using defaults")
		return
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary:
			if data.has("words") and data["words"] is Array:
				words_list = data["words"]
				_parse_words_list()
			if data.has("boxes"):
				boxes = data["boxes"]
			if data.has("total_games_played"):
				total_games_played = data["total_games_played"]
			if data.has("total_score"):
				total_score = data["total_score"]
			if data.has("words_mastered"):
				words_mastered = data["words_mastered"]
			print("LeitnerManager: Progress loaded, ", words.size(), " words")


func save_progress() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if not file:
		print("LeitnerManager: ERROR - Failed to save progress")
		return
	
	var current_time = Time.get_datetime_string_from_system()
	
	var save_data = {
		"version": "1.1",
		"last_updated": current_time,
		"words": words_list,
		"total_words_learned": _get_total_words_learned(),
		"statistics": {
			"total_games_played": total_games_played,
			"total_score": total_score,
			"words_mastered": words_mastered
		},
		"boxes": boxes
	}
	
	var json_str = JSON.stringify(save_data, "  ")
	
	file.store_string(json_str)
	file.close()
	print("LeitnerManager: Progress saved")
	progress_saved.emit()


func reset_game() -> void:
	current_game_words.clear()
	found_words.clear()


func import_words_from_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("LeitnerManager: ERROR - Failed to open file: ", path)
		return {"success": false, "error": "无法打开文件"}
	
	var content := file.get_as_text()
	file.close()
	
	return import_words_from_json(content)


func import_words_from_json(json_content: String) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(json_content)
	if error != OK:
		print("LeitnerManager: ERROR - JSON parse failed")
		return {"success": false, "error": "JSON格式错误"}
	
	var data = json.data
	if not (data is Dictionary and data.has("words") and data["words"] is Array):
		return {"success": false, "error": "无效的单词表格式"}
	
	var new_words = data["words"]
	var added_count = 0
	var skipped_count = 0
	
	for word_entry in new_words:
		if word_entry is Dictionary and word_entry.has("en"):
			var upper_word = word_entry["en"].to_upper()
			if not words.has(upper_word):
				words_list.append(word_entry)
				words[upper_word] = true
				if word_entry.has("zh"):
					word_meanings[upper_word] = word_entry["zh"]
				added_count += 1
			else:
				skipped_count += 1
	
	save_progress()
	print("LeitnerManager: Imported ", added_count, " new words, skipped ", skipped_count, " existing")
	
	return {
		"success": true,
		"added": added_count,
		"skipped": skipped_count,
		"total": words.size()
	}
