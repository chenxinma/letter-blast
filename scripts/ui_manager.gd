class_name UIManager

extends CanvasLayer

var score_label: Label
var found_words_label: Label
var word_meanings_label: Label
var word_manager: WordManager
var timer_manager: TimerManager
var score_manager: ScoreManager

var countdown_time: float = 30.0
var countdown_running: bool = false
var word_score_display_time: float = 0.0

signal countdown_finished()

func _ready() -> void:
	score_label = get_node_or_null("/root/Main/UI/ScoreLabel")
	found_words_label = get_node_or_null("/root/Main/UI/FoundWordsLabel")
	word_meanings_label = get_node_or_null("/root/Main/UI/WordMeaningsLabel")
	word_manager = get_node_or_null("/root/Main/WordManager")
	timer_manager = get_node_or_null("/root/Main/TimerManager")
	score_manager = get_node_or_null("/root/Main/ScoreManager")
	
	if score_manager:
		score_manager.connect("score_changed", _on_score_changed)
	
	update_ui()


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


func update_ui() -> void:
	if not score_label or not found_words_label:
		return

	var score = 0
	var found_words = []

	if word_manager:
		found_words = word_manager.get_found_words()

	if score_manager:
		score = score_manager.total_score

	score_label.text = "Score: %d" % score
	found_words_label.text = "Found: " + ", ".join(found_words)
	
	_update_word_meanings()


func _update_word_meanings() -> void:
	if not word_meanings_label or not word_manager:
		return
	
	var words_info = word_manager.get_level_words_info()
	if words_info.is_empty():
		word_meanings_label.text = ""
		return
	
	var display_text = "本关单词:\n"
	for word_info in words_info:
		var en = word_info.get("en", "")
		var zh = word_info.get("zh", "")
		var found = word_manager.is_word_found(en)
		if found:
			display_text += "[✓] %s - %s\n" % [en, zh]
		else:
			display_text += "[ ] %s - %s\n" % [en, zh]
	
	word_meanings_label.text = display_text


func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % score


func _on_score_changed(new_score: int) -> void:
	print("_on_score_changed", new_score)
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
			score_label.text = "Score: %d (%.1fs)" % [score_manager.total_score if score_manager else 0, countdown_time]


var _last_word_score: int = 0

func show_word_score(word_score: int) -> void:
	_last_word_score = word_score
	word_score_display_time = 1.5
	_update_countdown_display()


func reset_countdown() -> void:
	countdown_time = 30.0
	countdown_running = false
