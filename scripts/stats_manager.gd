extends Node

const STATS_FILE = "user://game_stats.json"

# 统计数据
var total_games: int = 0
var total_score: int = 0
var highest_score: int = 0
var win_streak: int = 0
var perfect_games: int = 0
var words_found: int = 0
var words_missed: int = 0
var total_play_time_seconds: int = 0
var matching_games_played: int = 0
var matching_perfect_rounds: int = 0

# 本局数据（临时）
var current_game_words_found: int = 0
var current_game_words_missed: int = 0
var current_game_score: int = 0
var current_game_start_time: int = 0

signal stats_updated


func _ready() -> void:
	load_stats()


func load_stats() -> void:
	var file := FileAccess.open(STATS_FILE, FileAccess.READ)
	if not file:
		print("StatsManager: No stats file found, initializing defaults")
		_save_default_stats()
		return
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary:
			total_games = data.get("total_games", 0)
			total_score = data.get("total_score", 0)
			highest_score = data.get("highest_score", 0)
			win_streak = data.get("win_streak", 0)
			perfect_games = data.get("perfect_games", 0)
			words_found = data.get("words_found", 0)
			words_missed = data.get("words_missed", 0)
			total_play_time_seconds = data.get("total_play_time_seconds", 0)
			matching_games_played = data.get("matching_games_played", 0)
			matching_perfect_rounds = data.get("matching_perfect_rounds", 0)
			print("StatsManager: Stats loaded successfully")
	else:
		print("StatsManager: Failed to parse stats, using defaults")
		_save_default_stats()


func save_stats() -> void:
	var file := FileAccess.open(STATS_FILE, FileAccess.WRITE)
	if not file:
		print("StatsManager: ERROR - Failed to save stats")
		return
	
	var save_data = {
		"total_games": total_games,
		"total_score": total_score,
		"highest_score": highest_score,
		"win_streak": win_streak,
		"perfect_games": perfect_games,
		"words_found": words_found,
		"words_missed": words_missed,
		"total_play_time_seconds": total_play_time_seconds,
		"matching_games_played": matching_games_played,
		"matching_perfect_rounds": matching_perfect_rounds
	}
	
	var json_str = JSON.stringify(save_data, "  ")
	file.store_string(json_str)
	file.close()
	emit_signal("stats_updated")
	print("StatsManager: Stats saved")


func _save_default_stats() -> void:
	total_games = 0
	total_score = 0
	highest_score = 0
	win_streak = 0
	perfect_games = 0
	words_found = 0
	words_missed = 0
	total_play_time_seconds = 0
	matching_games_played = 0
	matching_perfect_rounds = 0
	save_stats()


func start_new_game() -> void:
	current_game_words_found = 0
	current_game_words_missed = 0
	current_game_score = 0
	current_game_start_time = int(Time.get_unix_time_from_system())


func record_word_found() -> void:
	current_game_words_found += 1


func record_word_missed() -> void:
	current_game_words_missed += 1


func add_score(score: int) -> void:
	current_game_score += score


func complete_game(final_score: int, is_perfect: bool = false) -> void:
	current_game_score = final_score
	total_games += 1
	total_score += current_game_score
	
	if current_game_score > highest_score:
		highest_score = current_game_score
	
	win_streak += 1
	
	if is_perfect:
		perfect_games += 1
	
	words_found += current_game_words_found
	words_missed += current_game_words_missed
	
	var game_duration = int(Time.get_unix_time_from_system()) - current_game_start_time
	total_play_time_seconds += game_duration
	
	save_stats()


func reset_win_streak() -> void:
	win_streak = 0
	save_stats()


func record_matching_game(perfect: bool = false) -> void:
	matching_games_played += 1
	if perfect:
		matching_perfect_rounds += 1
	save_stats()


func get_stats() -> Dictionary:
	return {
		"total_games": total_games,
		"total_score": total_score,
		"highest_score": highest_score,
		"win_streak": win_streak,
		"perfect_games": perfect_games,
		"words_found": words_found,
		"words_missed": words_missed,
		"total_play_time_seconds": total_play_time_seconds,
		"matching_games_played": matching_games_played,
		"matching_perfect_rounds": matching_perfect_rounds
	}


func get_formatted_play_time() -> String:
	@warning_ignore("integer_division")
	var hours = total_play_time_seconds / 3600
	@warning_ignore("integer_division")
	var minutes = (total_play_time_seconds % 3600) / 60
	var seconds = total_play_time_seconds % 60
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%d:%02d" % [minutes, seconds]


func get_accuracy_rate() -> float:
	var total = words_found + words_missed
	if total == 0:
		return 0.0
	return float(words_found) / float(total) * 100.0
