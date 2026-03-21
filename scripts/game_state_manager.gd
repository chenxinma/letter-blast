extends Node
var last_game_words: Array = []
var last_game_words_info: Array = []
var last_game_score: int = 0
var last_game_time_remaining: int = 0
var last_game_found_words: Array = []
var last_game_missed_words: Array = []
var matching_game_score: int = 0

# 信号
signal data_cleared


func set_last_game_data(words: Array, words_info: Array, score: int, time_remaining: int, found: Array, missed: Array) -> void:
	last_game_words = words.duplicate()
	last_game_words_info = words_info.duplicate()
	last_game_score = score
	last_game_time_remaining = time_remaining
	last_game_found_words = found.duplicate()
	last_game_missed_words = missed.duplicate()


func get_last_game_words() -> Array:
	return last_game_words


func get_last_game_words_info() -> Array:
	return last_game_words_info


func get_last_game_score() -> int:
	return last_game_score


func get_last_game_time_remaining() -> int:
	return last_game_time_remaining


func get_last_game_found_words() -> Array:
	return last_game_found_words


func get_last_game_missed_words() -> Array:
	return last_game_missed_words


func set_matching_game_score(score: int) -> void:
	matching_game_score = score


func get_matching_game_score() -> int:
	return matching_game_score


func get_total_score() -> int:
	return last_game_score + matching_game_score


func clear_game_data() -> void:
	last_game_words.clear()
	last_game_words_info.clear()
	last_game_score = 0
	last_game_time_remaining = 0
	last_game_found_words.clear()
	last_game_missed_words.clear()
	matching_game_score = 0
	emit_signal("data_cleared")
