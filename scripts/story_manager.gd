class_name StoryManager

extends Node

const LEVELS_FILE = "res://data/levels.json"

var levels: Array = []
var unlocked_levels: Array = [1]
var current_level: int = 1
var level_progress: Dictionary = {}

func _ready() -> void:
	load_levels()
	load_progress()


func load_levels() -> bool:
	var file := FileAccess.open(LEVELS_FILE, FileAccess.READ)
	if not file:
		print("ERROR: Failed to open levels.json")
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary and data.has("levels"):
			levels = data["levels"]
			print("StoryManager: Loaded ", levels.size(), " levels")
			return true
		return false
	else:
		print("ERROR: JSON parse failed: ", json.get_error_message())
		return false


func get_level_config(level_num: int) -> Dictionary:
	for level_config in levels:
		if level_config.get("level") == level_num:
			return level_config
	return {}


func is_level_unlocked(level_num: int) -> bool:
	return level_num in unlocked_levels


func can_unlock_level(level_num: int) -> bool:
	if level_num > levels.size():
		return false
	
	var config = get_level_config(level_num)
	var unlock_condition = config.get("unlock_condition")
	
	if not unlock_condition:
		return true
	
	if unlock_condition.has("level_1_passed") and 1 in unlocked_levels:
		return true
	
	return false


func unlock_level(level_num: int) -> void:
	if level_num > levels.size():
		return
	if not is_level_unlocked(level_num):
		unlocked_levels.append(level_num)
		print("StoryManager: Level ", level_num, " unlocked")
		save_progress()


func pass_level(level_num: int) -> void:
	if level_num in unlocked_levels:
		var next_level = level_num + 1
		if can_unlock_level(next_level):
			unlock_level(next_level)
		level_progress[level_num] = {"passed": true, "timestamp": Time.get_unix_time_from_system()}
		save_progress()


func load_progress() -> void:
	var save_file = FileAccess.open("user://story_progress.json", FileAccess.READ)
	if not save_file:
		print("StoryManager: No save data found")
		return
	
	var content := save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		unlocked_levels = data.get("unlocked_levels", [1])
		level_progress = data.get("level_progress", {})
		current_level = unlocked_levels[unlocked_levels.size() - 1]
		print("StoryManager: Progress loaded, current level: ", current_level)


func save_progress() -> void:
	var save_file := FileAccess.open("user://story_progress.json", FileAccess.WRITE)
	if not save_file:
		print("ERROR: Failed to save progress")
		return
	
	var json_str = JSON.stringify({
		"unlocked_levels": unlocked_levels,
		"level_progress": level_progress,
		"current_level": current_level
	})
	
	save_file.store_string(json_str)
	save_file.close()
