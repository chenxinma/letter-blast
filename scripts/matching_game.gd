extends Control

# 节点引用
@onready var title_label: Label = $TitleLabel
@onready var progress_label: Label = $ProgressLabel
@onready var accuracy_label: Label = $AccuracyLabel
@onready var left_container: VBoxContainer = $GameArea/LeftContainer
@onready var right_container: VBoxContainer = $GameArea/RightContainer
@onready var line_container: Control = $GameArea/LineContainer
@onready var complete_panel: Panel = $CompletePanel
@onready var complete_title: Label = $CompletePanel/CompleteTitle
@onready var score_label: Label = $CompletePanel/ScoreLabel
@onready var bonus_label: Label = $CompletePanel/BonusLabel
@onready var continue_button: Button = $CompletePanel/ContinueButton
@onready var back_button: Button = $BackButton
@onready var word_button_sample: Button = $WordButtonSample
@onready var definition_button_sample: Button = $DefinitionButtonSample
@onready var click_player: AudioStreamPlayer = $ClickPlayer

# 常量
const MATCHING_SCENE = preload("res://scenes/matching_game.tscn")

# 游戏数据
var word_pairs: Array = []
var shuffled_meanings: Array = []
var selected_word_index: int = -1
var selected_meaning_index: int = -1
var connections: Dictionary = {}
var correct_count: int = 0
var wrong_attempts: int = 0
var matching_score: int = 0
var is_game_complete: bool = false

# 计分规则
const SCORE_PER_CORRECT: int = 20
const PENALTY_PER_WRONG: int = 5
const PERFECT_BONUS: int = 50

# 信号
signal matching_completed(score: int)


func _ready() -> void:
	_setup_ui()
	_initialize_game()
	back_button.pressed.connect(_on_back_pressed)
	continue_button.pressed.connect(_on_continue_pressed)


func _setup_ui() -> void:
	title_label.text = "🎯 记忆强化 - 连线挑战"
	progress_label.text = "进度: 0/0"
	accuracy_label.text = "正确率: 0%"
	complete_panel.visible = false


func _initialize_game() -> void:
	# 获取上局游戏的单词
	var words_info = GameStateManager.get_last_game_words_info()
	
	if words_info.is_empty():
		print("MatchingGame: No words from last game, returning to start screen")
		get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
		return
	
	# 创建单词-释义对
	word_pairs.clear()
	for word_info in words_info:
		var en = word_info.get("en", "")
		var zh = word_info.get("zh", "")
		if not en.is_empty() and not zh.is_empty():
			word_pairs.append({"en": en, "zh": zh, "index": word_pairs.size()})
	
	# 打乱释义顺序
	shuffled_meanings = word_pairs.duplicate()
	shuffled_meanings.shuffle()
	
	# 重置游戏状态
	selected_word_index = -1
	selected_meaning_index = -1
	connections.clear()
	correct_count = 0
	wrong_attempts = 0
	matching_score = 0
	is_game_complete = false
	
	# 创建UI元素
	_create_word_buttons()
	_create_meaning_buttons()
	_update_progress()


func _create_word_buttons() -> void:
	for child in left_container.get_children():
		child.queue_free()
	
	var sample_style = word_button_sample.get_theme_stylebox("normal")
	var sample_pressed_style = word_button_sample.get_theme_stylebox("pressed")
	var sample_hover_style = word_button_sample.get_theme_stylebox("hover")
	
	for i in range(word_pairs.size()):
		var word_data = word_pairs[i]
		var button = Button.new()
		button.text = word_data["en"]
		button.custom_minimum_size = word_button_sample.custom_minimum_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_stylebox_override("normal", sample_style)
		button.add_theme_stylebox_override("pressed", sample_pressed_style)
		button.add_theme_stylebox_override("hover", sample_hover_style)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_constant_override("outline_size", 4)
		
		button.pressed.connect(_on_word_button_pressed.bind(i))
		button.name = "WordButton_%d" % i
		left_container.add_child(button)


func _create_meaning_buttons() -> void:
	for child in right_container.get_children():
		child.queue_free()
	
	var sample_style = definition_button_sample.get_theme_stylebox("normal")
	var sample_pressed_style = definition_button_sample.get_theme_stylebox("pressed")
	var sample_hover_style = definition_button_sample.get_theme_stylebox("hover")
	
	for i in range(shuffled_meanings.size()):
		var meaning_data = shuffled_meanings[i]
		var button = Button.new()
		button.text = meaning_data["zh"]
		button.custom_minimum_size = definition_button_sample.custom_minimum_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_stylebox_override("normal", sample_style)
		button.add_theme_stylebox_override("pressed", sample_pressed_style)
		button.add_theme_stylebox_override("hover", sample_hover_style)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_constant_override("outline_size", 4)
		button.pressed.connect(_on_meaning_button_pressed.bind(i))
		button.name = "MeaningButton_%d" % i
		right_container.add_child(button)


func _on_word_button_pressed(index: int) -> void:
	if is_game_complete or connections.has(index):
		return
	
	click_player.play()
	selected_word_index = index
	_highlight_word_button(index)
	
	# 检查是否已选择了释义
	if selected_meaning_index >= 0:
		_check_match()


func _on_meaning_button_pressed(index: int) -> void:
	if is_game_complete:
		return
	
	click_player.play()
	
	# 检查这个释义是否已经被匹配
	var already_matched = false
	for word_idx in connections:
		if connections[word_idx] == index:
			already_matched = true
			break
	
	if already_matched:
		return
	
	selected_meaning_index = index
	_highlight_meaning_button(index)
	
	# 检查是否已选择了单词
	if selected_word_index >= 0:
		_check_match()


func _highlight_word_button(index: int) -> void:
	# 重置所有单词按钮样式
	for i in range(word_pairs.size()):
		var button = left_container.get_child(i)
		if connections.has(i):
			_set_button_matched_style(button)
		else:
			_set_button_normal_style(button)
	
	# 高亮选中的按钮
	if index >= 0 and not connections.has(index):
		var selected_button = left_container.get_child(index)
		_set_button_selected_style(selected_button)


func _highlight_meaning_button(index: int) -> void:
	for i in range(shuffled_meanings.size()):
		var button = right_container.get_child(i)
		var is_matched = false
		for word_idx in connections:
			if connections[word_idx] == i:
				is_matched = true
				break
		
		if is_matched:
			_set_button_matched_style(button)
		else:
			_set_meaning_button_normal_style(button)
	
	if index >= 0:
		var is_matched = false
		for word_idx in connections:
			if connections[word_idx] == index:
				is_matched = true
				break
		
		if not is_matched:
			var selected_button = right_container.get_child(index)
			_set_meaning_button_selected_style(selected_button)


func _set_button_normal_style(button: Button) -> void:
	var sample_style = word_button_sample.get_theme_stylebox("normal")
	var sample_pressed_style = word_button_sample.get_theme_stylebox("pressed")
	var sample_hover_style = word_button_sample.get_theme_stylebox("hover")
	
	button.add_theme_stylebox_override("normal", sample_style)
	button.add_theme_stylebox_override("pressed", sample_pressed_style)
	button.add_theme_stylebox_override("hover", sample_hover_style)


func _set_button_selected_style(button: Button) -> void:
	var sample_style = word_button_sample.get_theme_stylebox("pressed")
	button.add_theme_stylebox_override("normal", sample_style)
	button.add_theme_stylebox_override("pressed", sample_style)
	button.add_theme_stylebox_override("hover", sample_style)


func _set_button_matched_style(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.8, 0.2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("hover", style)


func _set_button_wrong_style(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 0.7, 0.7)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("hover", style)


func _set_meaning_button_normal_style(button: Button) -> void:
	var sample_style = definition_button_sample.get_theme_stylebox("normal")
	var sample_pressed_style = definition_button_sample.get_theme_stylebox("pressed")
	var sample_hover_style = definition_button_sample.get_theme_stylebox("hover")
	
	button.add_theme_stylebox_override("normal", sample_style)
	button.add_theme_stylebox_override("pressed", sample_pressed_style)
	button.add_theme_stylebox_override("hover", sample_hover_style)


func _set_meaning_button_selected_style(button: Button) -> void:
	var sample_style = definition_button_sample.get_theme_stylebox("pressed")
	button.add_theme_stylebox_override("normal", sample_style)
	button.add_theme_stylebox_override("pressed", sample_style)
	button.add_theme_stylebox_override("hover", sample_style)


func _check_match() -> void:
	if selected_word_index < 0 or selected_meaning_index < 0:
		return
	
	var word_data = word_pairs[selected_word_index]
	var meaning_data = shuffled_meanings[selected_meaning_index]
	
	if word_data["en"] == meaning_data["en"]:
		# 匹配成功
		_handle_correct_match()
	else:
		# 匹配失败
		_handle_wrong_match()


func _handle_correct_match() -> void:
	connections[selected_word_index] = selected_meaning_index
	correct_count += 1
	matching_score += SCORE_PER_CORRECT
	
	# 更新按钮样式
	var word_button = left_container.get_child(selected_word_index)
	var meaning_button = right_container.get_child(selected_meaning_index)
	_set_button_matched_style(word_button)
	_set_button_matched_style(meaning_button)
	
	# 绘制连线
	_draw_connection_line(selected_word_index, selected_meaning_index, Color(0.2, 0.8, 0.2))
	
	# 重置选择
	selected_word_index = -1
	selected_meaning_index = -1
	
	_update_progress()
	
	# 检查是否完成
	if correct_count >= word_pairs.size():
		_game_complete()


func _handle_wrong_match() -> void:
	wrong_attempts += 1
	matching_score = max(0, matching_score - PENALTY_PER_WRONG)
	
	# 显示错误效果
	var word_button = left_container.get_child(selected_word_index)
	var meaning_button = right_container.get_child(selected_meaning_index)
	
	# 立即重置选择状态，防止在等待期间用户继续操作
	selected_word_index = -1
	selected_meaning_index = -1
	
	_set_button_wrong_style(word_button)
	_set_button_wrong_style(meaning_button)
	
	# 延迟后重置
	await get_tree().create_timer(0.5).timeout
	
	# 检查按钮是否仍然有效（防止场景切换后访问无效节点）
	if not is_instance_valid(word_button) or not is_instance_valid(meaning_button):
		return
	if word_button not in left_container.get_children() or meaning_button not in right_container.get_children():
		return
	
	_set_button_normal_style(word_button)
	_set_meaning_button_normal_style(meaning_button)
	
	_update_progress()


func _draw_connection_line(word_index: int, meaning_index: int, color: Color) -> void:
	var line = Line2D.new()
	line.default_color = color
	line.width = 4
	
	# 计算按钮位置
	var word_button = left_container.get_child(word_index)
	var meaning_button = right_container.get_child(meaning_index)
	
	var word_pos = word_button.global_position + Vector2(word_button.size.x, word_button.size.y / 2)
	var meaning_pos = meaning_button.global_position + Vector2(0, meaning_button.size.y / 2)
	
	# 转换为LineContainer的本地坐标（手动计算）
	var container_global_pos = line_container.global_position
	word_pos = word_pos - container_global_pos
	meaning_pos = meaning_pos - container_global_pos
	
	line.add_point(word_pos)
	line.add_point(meaning_pos)
	line.name = "Connection_%d_%d" % [word_index, meaning_index]
	
	line_container.add_child(line)


func _update_progress() -> void:
	progress_label.text = "进度: %d/%d" % [correct_count, word_pairs.size()]
	
	var total_attempts = correct_count + wrong_attempts
	if total_attempts > 0:
		var accuracy = float(correct_count) / float(total_attempts) * 100
		accuracy_label.text = "正确率: %d%%" % int(accuracy)
	else:
		accuracy_label.text = "正确率: 0%"


func _game_complete() -> void:
	is_game_complete = true
	
	# 计算完美奖励
	var is_perfect = wrong_attempts == 0
	if is_perfect:
		matching_score += PERFECT_BONUS
	
	# 保存分数
	GameStateManager.set_matching_game_score(matching_score)
	
	# 记录统计数据
	StatsManager.record_matching_game(is_perfect)
	
	# 显示完成界面
	_show_complete_panel(is_perfect)


func _show_complete_panel(is_perfect: bool) -> void:
	complete_panel.visible = true
	
	if is_perfect:
		complete_title.text = "🎉 完美完成！"
		bonus_label.text = "完美奖励: +%d 分" % PERFECT_BONUS
	else:
		complete_title.text = "✅ 挑战完成"
		bonus_label.text = ""
	
	var base_score = correct_count * SCORE_PER_CORRECT
	var penalty = wrong_attempts * PENALTY_PER_WRONG
	
	score_label.text = "基础得分: %d\n错误扣分: -%d\n连线游戏总分: %d" % [base_score, penalty, matching_score]


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func _on_continue_pressed() -> void:
	# 发送完成信号
	emit_signal("matching_completed", matching_score)
	
	# 切换到结算界面
	get_tree().change_scene_to_file("res://scenes/game_complete_screen.tscn")
