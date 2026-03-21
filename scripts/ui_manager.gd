extends CanvasLayer

var score_label: Label
var found_words_label: Label
var word_meanings_label: Label
var box_stats_label: Label
var timer_label: Label
var leitner_manager: Node
var timer_manager: TimerManager
var score_manager: ScoreManager
var settings_manager: Node

var countdown_time: float = 30.0
var countdown_running: bool = false
var word_score_display_time: float = 0.0

# 提示模式相关
var hint_mode_container: HBoxContainer
var hint_mode_buttons: Dictionary = {}
var both_button: Button
var zh_only_button: Button
var en_only_button: Button

var _last_word_score: int = 0

signal countdown_finished()
signal hint_mode_changed(mode: int)


func _ready() -> void:
	_find_nodes()
	_setup_settings_manager()
	if score_manager:
		score_manager.connect("score_changed", _on_score_changed)
	
	update_ui()


func _setup_settings_manager() -> void:
	settings_manager = get_node_or_null("/root/SettingsManager")
	if not settings_manager:
		var settings_script = load("res://scripts/settings_manager.gd")
		settings_manager = settings_script.new()
		settings_manager.name = "SettingsManager"
		get_tree().root.add_child(settings_manager)
	
	settings_manager.connect("hint_mode_changed", _on_hint_mode_changed)


func _find_nodes() -> void:
	if not score_label:
		score_label = get_node_or_null("/root/Main2D/UI/ScoreLabel")
	
	if not found_words_label:
		found_words_label = get_node_or_null("/root/Main2D/UI/FoundWordsLabel")
	
	if not word_meanings_label:
		word_meanings_label = get_node_or_null("/root/Main2D/Hint/HintPanel/WordMeaningsLabel")
	
	if not box_stats_label:
		box_stats_label = get_node_or_null("/root/Main2D/UI/BoxStatsLabel")
	
	if not timer_label:
		timer_label = get_node_or_null("/root/Main2D/UI/TimerLabel")
	
	# 查找提示模式容器和按钮
	hint_mode_container = get_node_or_null("/root/Main2D/UI/HintModeContainer")
	both_button = get_node_or_null("/root/Main2D/UI/HintModeContainer/BothButton")
	zh_only_button = get_node_or_null("/root/Main2D/UI/HintModeContainer/ZhOnlyButton")
	en_only_button = get_node_or_null("/root/Main2D/UI/HintModeContainer/EnOnlyButton")
	
	# 连接按钮信号
	if both_button and not both_button.pressed.is_connected(_on_both_button_pressed):
		both_button.pressed.connect(_on_both_button_pressed)
		hint_mode_buttons["0"] = both_button
	
	if zh_only_button and not zh_only_button.pressed.is_connected(_on_zh_only_button_pressed):
		zh_only_button.pressed.connect(_on_zh_only_button_pressed)
		hint_mode_buttons["1"] = zh_only_button
	
	if en_only_button and not en_only_button.pressed.is_connected(_on_en_only_button_pressed):
		en_only_button.pressed.connect(_on_en_only_button_pressed)
		hint_mode_buttons["2"] = en_only_button
	
	_update_hint_mode_buttons()


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


func _update_word_meanings() -> void:
	if not word_meanings_label or not leitner_manager:
		return
	
	var words_info = leitner_manager.get_current_game_words_info()
	if words_info.is_empty():
		word_meanings_label.text = ""
		return
	
	# 根据提示模式决定显示内容
	var display_text = "本局单词:\n"
	var ln = ""
	for word_info in words_info:
		var en = word_info.get("en", "")
		var zh = word_info.get("zh", "")
		var found = leitner_manager.is_word_found(en)
		var status = "[✓]" if found else "[ ]"
		
		# 根据当前提示模式格式化显示
		var display_content = _get_word_display_text(en, zh)
		
		if found:
			display_text += "%s%s %s" % [ln, status, display_content]
		else:
			display_text += "%s%s %s" % [ln, status, display_content]
		ln = "\n"
	
	word_meanings_label.text = display_text


func _get_word_display_text(en: String, zh: String) -> String:
	if not settings_manager:
		return "%s (%s)" % [en, zh]
	
	return settings_manager.get_display_text_for_word(en, zh)


func _on_hint_mode_changed(mode: int) -> void:
	_update_word_meanings()
	_update_hint_mode_buttons()
	emit_signal("hint_mode_changed", mode)


func _update_hint_mode_buttons() -> void:
	if not hint_mode_container:
		return
	
	# 更新按钮高亮状态
	if settings_manager:
		var current_mode = settings_manager.get_hint_mode()
		for mode_key in hint_mode_buttons:
			var button = hint_mode_buttons[mode_key]
			var mode_value = int(mode_key)
			if mode_value == current_mode:
				_set_button_active_style(button)
			else:
				_set_button_normal_style(button)


func _set_button_active_style(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.6, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_color_override("font_color", Color(1, 1, 1))


func _set_button_normal_style(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.85, 0.85, 0.85)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))


func set_hint_mode(mode: int) -> void:
	if settings_manager:
		settings_manager.set_hint_mode(mode)


func get_current_hint_mode() -> int:
	if settings_manager:
		return settings_manager.get_hint_mode()
	return 0  # BOTH mode


func _on_both_button_pressed() -> void:
	set_hint_mode(0)


func _on_zh_only_button_pressed() -> void:
	set_hint_mode(1)


func _on_en_only_button_pressed() -> void:
	set_hint_mode(2)


func _on_score_changed(new_score: int) -> void:
	update_score(new_score)


func _update_countdown_display() -> void:
	if score_label:
		if word_score_display_time > 0:
			score_label.text = "Score: %d (+%d)" % [score_manager.total_score if score_manager else 0, _last_word_score]
		else:
			score_label.text = "Score: %d" % [score_manager.total_score if score_manager else 0]


func show_word_score(word_score: int) -> void:
	_last_word_score = word_score
	word_score_display_time = 1.5
	_update_countdown_display()


func reset_countdown() -> void:
	countdown_time = 30.0
	countdown_running = false


func start_countdown() -> void:
	countdown_running = true
