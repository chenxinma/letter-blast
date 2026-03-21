extends Control

# 节点引用
@onready var title_label: Label = $TitleLabel
@onready var total_words_label: Label = $MainContainer/StatsSection/StatsRow/TotalWordsLabel
@onready var learned_words_label: Label = $MainContainer/StatsSection/StatsRow/LearnedWordsLabel
@onready var mastery_progress_bar: ProgressBar = $MainContainer/StatsSection/MasteryHBox/MasteryProgressBar
@onready var mastery_percentage_label: Label = $MainContainer/StatsSection/MasteryHBox/MasteryPercentageLabel
@onready var box_container: VBoxContainer = $MainContainer/LeitnerSection/BoxContainer
@onready var review_list: VBoxContainer = $MainContainer/ReviewSection/ReviewList
@onready var stats_container: VBoxContainer = $MainContainer/AchievementSection/StatsContainer
@onready var back_button: Button = $BackButton
@onready var start_review_button: Button = $StartReviewButton

# Leitner Box 间隔天数
const BOX_INTERVALS = [1, 2, 4, 7, 14]
const BOX_COLORS = [
	Color(0.9, 0.3, 0.3),   # Box 1 - 红色
	Color(0.9, 0.6, 0.2),   # Box 2 - 橙色
	Color(0.9, 0.9, 0.2),   # Box 3 - 黄色
	Color(0.3, 0.9, 0.3),   # Box 4 - 浅绿色
	Color(0.2, 0.7, 0.2)    # Box 5 - 深绿色
]

# 数据
var leitner_manager: Node
var stats_manager: Node


func _ready() -> void:
	_setup_references()
	_setup_ui()
	_load_and_display_data()
	back_button.pressed.connect(_on_back_pressed)


func _setup_references() -> void:
	# 获取LeitnerManager
	leitner_manager = get_node_or_null("/root/LeitnerManager")
	
	# 获取StatsManager
	stats_manager = get_node_or_null("/root/StatsManager")


func _setup_ui() -> void:
	title_label.text = "📊 学习进度"


func _load_and_display_data() -> void:
	_display_word_stats()
	_display_leitner_boxes()
	_display_review_list()
	_display_achievement_stats()


func _display_word_stats() -> void:
	var box_stats = leitner_manager.get_box_stats()
	var total_learned = 0
	var total_mastered = box_stats.get(5, 0)
	
	for i in range(1, 6):
		total_learned += box_stats.get(i, 0)
	
	var total_words = leitner_manager.words.size()
	var pending_words = total_words - total_learned
	
	total_words_label.text = "总单词数: %d" % total_words
	learned_words_label.text = "已学习: %d   待学习: %d" % [total_learned, pending_words]
	
	# 掌握度计算（基于Box 5的单词占比）
	var mastery_percent = 0
	if total_words > 0:
		mastery_percent = int(float(total_mastered) / float(total_words) * 100)
	
	mastery_progress_bar.value = mastery_percent
	mastery_percentage_label.text = "%d%%" % mastery_percent


func _display_leitner_boxes() -> void:
	# 清除旧的显示
	for child in box_container.get_children():
		child.queue_free()
	
	var box_stats = leitner_manager.get_box_stats()
	var max_count = 1
	
	# 找出最大数量用于计算比例
	for i in range(1, 6):
		max_count = max(max_count, box_stats.get(i, 0))
	
	# 创建每个Box的显示
	for i in range(1, 6):
		var box_num = i
		var count = box_stats.get(box_num, 0)
		var interval = BOX_INTERVALS[box_num - 1]
		var color = BOX_COLORS[box_num - 1]
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.custom_minimum_size = Vector2(0, 30)
		
		# Box标签
		var label = Label.new()
		label.text = "Box %d (%d天):" % [box_num, interval]
		label.custom_minimum_size = Vector2(100, 0)
		label.add_theme_font_size_override("font_size", 14)
		hbox.add_child(label)
		
		# 进度条容器
		var progress_container = MarginContainer.new()
		progress_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress_container.add_theme_constant_override("margin_right", 10)
		hbox.add_child(progress_container)
		
		# 进度条
		var progress = ProgressBar.new()
		progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress.value = float(count) / float(max_count) * 100
		progress.min_value = 0
		progress.max_value = 100
		
		# 自定义进度条样式
		var fg_style = StyleBoxFlat.new()
		fg_style.bg_color = color
		progress.add_theme_stylebox_override("fill", fg_style)
		
		progress_container.add_child(progress)
		
		# 数量标签
		var count_label = Label.new()
		count_label.text = "%d 词" % count
		if box_num == 5:
			count_label.text += " (已掌握)"
		count_label.custom_minimum_size = Vector2(80, 0)
		count_label.add_theme_font_size_override("font_size", 14)
		hbox.add_child(count_label)
		
		box_container.add_child(hbox)


func _display_review_list() -> void:
	# 清除旧的列表
	for child in review_list.get_children():
		child.queue_free()
	
	# 获取今日待复习单词
	var words_to_review = _get_words_to_review()
	
	if words_to_review.is_empty():
		var empty_label = Label.new()
		empty_label.text = "今日暂无待复习单词，真棒！"
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2, 1))
		review_list.add_child(empty_label)
	else:
		for word_data in words_to_review:
			var hbox = HBoxContainer.new()
			
			var word_label = Label.new()
			word_label.text = "[%s]" % word_data["word"]
			word_label.add_theme_font_size_override("font_size", 14)
			word_label.custom_minimum_size = Vector2(120, 0)
			hbox.add_child(word_label)
			
			var days_label = Label.new()
			days_label.text = "- 已学习 %d 天" % word_data["days_since"]
			days_label.add_theme_font_size_override("font_size", 14)
			hbox.add_child(days_label)
			
			review_list.add_child(hbox)


func _get_words_to_review() -> Array:
	var words_to_review = []
	
	for box_num in range(1, 6):
		var box_key = "box" + str(box_num)
		var interval = BOX_INTERVALS[box_num - 1]
		
		for word_data in leitner_manager.boxes[box_key]:
			var days_since = _days_since(word_data.get("last_reviewed", ""))
			if days_since >= interval:
				words_to_review.append({
					"word": word_data["word"],
					"days_since": days_since,
					"box": box_num
				})
	
	# 限制显示数量
	if words_to_review.size() > 5:
		words_to_review.resize(5)
	
	return words_to_review


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


func _display_achievement_stats() -> void:
	# 清除旧的显示
	for child in stats_container.get_children():
		child.queue_free()
	
	var stats = stats_manager.get_stats()
	
	var stat_items = [
		{"label": "总得分", "value": str(stats["total_score"])},
		{"label": "最高分", "value": str(stats["highest_score"])},
		{"label": "已找到单词", "value": str(stats["words_found"])},
		{"label": "准确率", "value": "%.1f%%" % stats_manager.get_accuracy_rate()},
		{"label": "完美通关", "value": str(stats["perfect_games"])},
		{"label": "游戏时长", "value": stats_manager.get_formatted_play_time()},
	]
	
	# 分两列显示
	var hbox = HBoxContainer.new()
	stats_container.add_child(hbox)
	
	var left_column = VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(left_column)
	
	var right_column = VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_column)
	
	for i in range(stat_items.size()):
		var item = stat_items[i]
		var label = Label.new()
		label.text = "%s: %s" % [item["label"], item["value"]]
		label.add_theme_font_size_override("font_size", 14)
		
		if i < stat_items.size() / 2.0:
			left_column.add_child(label)
		else:
			right_column.add_child(label)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
