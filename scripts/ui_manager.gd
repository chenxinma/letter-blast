class_name UIManager

extends CanvasLayer

var score_label: Label
var found_words_label: Label
var word_meanings_label: Label
var box_stats_label: Label
var timer_label: Label
var leitner_manager: Node
var timer_manager: TimerManager
var score_manager: ScoreManager

var countdown_time: float = 30.0
var countdown_running: bool = false
var word_score_display_time: float = 0.0

signal countdown_finished()


func _ready() -> void:
	_find_nodes()
	if score_manager:
		score_manager.connect("score_changed", _on_score_changed)
	
	update_ui()


func _find_nodes() -> void:
	if not score_label:
		score_label = get_node_or_null("/root/Main2D/UI/ScoreLabel")
	
	if not found_words_label:
		found_words_label = get_node_or_null("/root/Main2D/UI/FoundWordsLabel")
	
	if not word_meanings_label:
		word_meanings_label = get_node_or_null("/root/Main2D/Hint/WordMeaningsLabel")
	
	if not box_stats_label:
		box_stats_label = get_node_or_null("/root/Main2D/UI/BoxStatsLabel")
	
	if not timer_label:
		timer_label = get_node_or_null("/root/Main2D/UI/TimerLabel")


func _process(delta: float) -> void:
	if countdown_running:
		countdown_time -= delta
		if countdown_time <= 0:
			countdown_time = 0
			countdown_running = false
			emit_signal("countdown_finished")
		_update_countdown_display()
	
	if word_score_display_time > 0:
		word_score_display_time -= delta
	
	_update_timer_display()


func _update_timer_display() -> void:
	if timer_label and timer_manager:
		var time_left: int = timer_manager.time_remaining
		@warning_ignore("integer_division")
		var minutes: int = time_left / 60
		var seconds: int = time_left % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]


func update_ui() -> void:
	if not score_label or not found_words_label:
		return

	var score = 0
	var found_words = []

	if leitner_manager:
		found_words = leitner_manager.get_found_words()

	if score_manager:
		score = score_manager.total_score

	score_label.text = "Score: %d" % score
	found_words_label.text = "Found: " + ", ".join(found_words)
	
	_update_word_meanings()
	_update_box_stats()


func _update_word_meanings() -> void:
	if not word_meanings_label or not leitner_manager:
		return
	
	var words_info = leitner_manager.get_current_game_words_info()
	if words_info.is_empty():
		word_meanings_label.text = ""
		return
	
	var display_text = "本局单词:\n"
	var ln = ""
	for word_info in words_info:
		var en = word_info.get("en", "")
		var zh = word_info.get("zh", "")
		var found = leitner_manager.is_word_found(en)
		if found:
			display_text += "%s[✓] %s - %s" % [ln, en, zh]
		else:
			display_text += "%s[ ] %s - %s" % [ln, en, zh]
		ln = "\n"
	
	word_meanings_label.text = display_text


func _update_box_stats() -> void:
	if not box_stats_label or not leitner_manager:
		return
	
	var stats = leitner_manager.get_box_stats()
	var text = "学习进度: "
	for i in range(1, 6):
		text += "Box%d(%d) " % [i, stats.get(i, 0)]
	
	box_stats_label.text = text


func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % score


func _on_score_changed(new_score: int) -> void:
	update_score(new_score)


func start_countdown() -> void:
	if not countdown_running:
		countdown_time = 30.0
		countdown_running = true
		_update_countdown_display()


func _update_countdown_display() -> void:
	if score_label:
		if word_score_display_time > 0:
			score_label.text = "Score: %d (+%d)" % [score_manager.total_score if score_manager else 0, _last_word_score]
		else:
			score_label.text = "Score: %d" % [score_manager.total_score if score_manager else 0]


var _last_word_score: int = 0


func show_word_score(word_score: int) -> void:
	_last_word_score = word_score
	word_score_display_time = 1.5
	_update_countdown_display()


func reset_countdown() -> void:
	countdown_time = 30.0
	countdown_running = false
