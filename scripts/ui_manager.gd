class_name UIManager

extends CanvasLayer

var level_label: Label
var score_label: Label
var time_label: Label
var word_count_label: Label
var found_words_label: Label
var word_manager: WordManager
var timer_manager: TimerManager
var score_manager: ScoreManager

func _ready() -> void:
	level_label = get_node_or_null("/root/Main/UI/LevelLabel")
	score_label = get_node_or_null("/root/Main/UI/ScoreLabel")
	time_label = get_node_or_null("/root/Main/UI/TimeLabel")
	word_count_label = get_node_or_null("/root/Main/UI/WordCountLabel")
	found_words_label = get_node_or_null("/root/Main/UI/FoundWordsLabel")
	word_manager = get_node_or_null("/root/Main/WordManager")
	timer_manager = get_node_or_null("/root/Main/TimerManager")
	score_manager = get_node_or_null("/root/Main/ScoreManager")
	update_ui()


func _process(_delta: float) -> void:
	pass


func update_ui() -> void:
	if not level_label or not score_label or not time_label or not word_count_label or not found_words_label:
		return

	var level = 1
	var score = 0
	var time_remaining = 0
	var remaining_words = []
	var found_words = []

	if word_manager:
		remaining_words = word_manager.get_remaining_words()
		found_words = word_manager.get_found_words()

	if timer_manager:
		time_remaining = timer_manager.time_remaining

	if score_manager:
		level = score_manager.current_level
		score = score_manager.total_score

	level_label.text = "Level: %d" % level
	score_label.text = "Score: %d" % score
	time_label.text = "Time: %ds" % time_remaining
	word_count_label.text = "Words left: %d" % remaining_words.size()
	found_words_label.text = "Found: " + ", ".join(found_words)


func update_level(level: int) -> void:
	if level_label:
		level_label.text = "Level: %d" % level


func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % score


func update_time(seconds: int) -> void:
	if time_label:
		time_label.text = "Time: %ds" % seconds
