class_name ScoreManager

extends Node

var total_score: int = 0
var level_score: int = 0
var found_words: Array = []
var current_level: int = 1

signal score_changed(new_score: int)
signal level_complete(score: int, time_bonus: int, total: int)


func _ready() -> void:
	pass


func calculate_word_score(word: String) -> int:
	var length = word.length()
	var base_score: int
	var difficulty_multiplier: float
	
	if length <= 3:
		base_score = 10
		difficulty_multiplier = 1.0
	elif length <= 5:
		base_score = 20
		difficulty_multiplier = 1.5
	elif length <= 7:
		base_score = 40
		difficulty_multiplier = 2.0
	else:
		base_score = 80
		difficulty_multiplier = 3.0
	
	return int(base_score * difficulty_multiplier)


func add_score(word: String, time_remaining: int = 0) -> int:
	var word_score = calculate_word_score(word)
	level_score += word_score
	total_score += word_score
	found_words.append(word)
	
	var time_bonus = 0
	if time_remaining > 0:
		time_bonus = int(time_remaining * 0.5)
		total_score += time_bonus
		level_score += time_bonus
	#print(total_score)
	emit_signal("score_changed", total_score)
	return word_score + time_bonus


func calculate_perfect_bonus(time_remaining: int, time_limit: int) -> int:
	if time_limit == 0:
		return 0
	var time_percent = float(time_remaining) / float(time_limit)
	if time_percent > 0.5:
		return 100
	return 0


func complete_level(time_remaining: int, time_limit: int) -> Dictionary:
	var level_complete_score = level_score
	var perfect_bonus = calculate_perfect_bonus(time_remaining, time_limit)
	var total = level_complete_score + perfect_bonus
	
	total_score += perfect_bonus
	level_score = 0
	
	emit_signal("level_complete", level_complete_score, perfect_bonus, total)
	emit_signal("score_changed", total_score)
	
	return {
		"level_score": level_complete_score,
		"perfect_bonus": perfect_bonus,
		"total": total
	}


func reset_level() -> void:
	level_score = 0
	found_words.clear()
	emit_signal("score_changed", total_score)


func set_level(level_num: int) -> void:
	current_level = level_num


func get_total_score() -> int:
	return total_score


func reset_all() -> void:
	total_score = 0
	level_score = 0
	found_words.clear()
	current_level = 1
	emit_signal("score_changed", 0)
