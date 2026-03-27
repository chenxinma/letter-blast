extends Control

@onready var progress_title: Label = $CardContainer/PinkCard/MarginContainer/VBoxContainer/ProgressTitle
@onready var progress_subtitle: Label = $CardContainer/PinkCard/MarginContainer/VBoxContainer/ProgressSubtitle
@onready var main_progress_bar: ProgressBar = $CardContainer/PinkCard/MarginContainer/VBoxContainer/ProgressBarContainer/ProgressBar
@onready var box_container: HBoxContainer = $CardContainer/PinkCard/MarginContainer/VBoxContainer/BoxContainer
@onready var badge_container: GridContainer = $CardContainer/YellowCard/MarginContainer/VBoxContainer/BadgeContainer
@onready var back_button: Button = $BackButton

var box_labels: Array[Label] = []
var box_bars: Array[ProgressBar] = []
var box_counts: Array[Label] = []

const BOX_COLORS = [
	Color(0.9, 0.3, 0.3),
	Color(0.9, 0.6, 0.2),
	Color(0.9, 0.9, 0.2),
	Color(0.3, 0.9, 0.3),
	Color(0.2, 0.7, 0.2)
]

const BadgeScene = preload("res://scenes/badge.tscn")

var leitner_manager: Node
var stats_manager: Node


func _ready() -> void:
	_setup_references()
	_setup_box_references()
	_setup_ui()
	_load_and_display_data()
	back_button.pressed.connect(_on_back_pressed)


func _setup_references() -> void:
	# 获取LeitnerManager
	leitner_manager = get_node_or_null("/root/LeitnerManager")
	
	# 获取StatsManager
	stats_manager = get_node_or_null("/root/StatsManager")


func _setup_box_references() -> void:
	# 获取5个BOX的引用
	for i in range(1, 6):
		var box = box_container.get_node("Box" + str(i))
		box_labels.append(box.get_node("BoxLabel" + str(i)))
		box_bars.append(box.get_node("BoxBarContainer" + str(i) + "/BoxBar" + str(i)))
		box_counts.append(box.get_node("BoxCount" + str(i)))


func _setup_ui() -> void:
	_setup_progress_bar_style(main_progress_bar, Color(0.4, 0.8, 1.0))
	
	for i in range(5):
		_setup_progress_bar_style(box_bars[i], BOX_COLORS[i])


func _setup_progress_bar_style(progress_bar: ProgressBar, fill_color: Color) -> void:
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(1, 1, 1, 1)
	progress_bar.add_theme_stylebox_override("background", bg_style)
	
	var fg_style = StyleBoxFlat.new()
	fg_style.bg_color = fill_color
	progress_bar.add_theme_stylebox_override("fill", fg_style)


func _load_and_display_data() -> void:
	_display_word_stats()
	_display_leitner_boxes()
	_display_badges()


func _display_word_stats() -> void:
	var box_stats = leitner_manager.get_box_stats()
	var total_learned = 0
	
	for i in range(1, 6):
		total_learned += box_stats.get(i, 0)
	
	var total_words = leitner_manager.words.size()
	
	progress_title.text = "%d/%d" % [total_learned, total_words]
	progress_subtitle.text = "(已经学习单词数 / 收录单词数)"
	
	# 主进度条
	var progress_percent = 0
	if total_words > 0:
		progress_percent = float(total_learned) / float(total_words) * 100
	main_progress_bar.value = progress_percent


func _display_leitner_boxes() -> void:
	var box_stats = leitner_manager.get_box_stats()
	var max_count = 1
	
	for i in range(1, 6):
		max_count = max(max_count, box_stats.get(i, 0))
	
	for i in range(5):
		var box_num = i + 1
		var count = box_stats.get(box_num, 0)
		
		box_labels[i].text = "BOX %d" % box_num
		box_counts[i].text = str(count)
		
		var percent = 0
		if max_count > 0:
			percent = float(count) / float(max_count) * 100
		box_bars[i].value = percent


func _display_badges() -> void:
	for child in badge_container.get_children():
		child.queue_free()
	
	if stats_manager == null:
		return
	
	var stats = stats_manager.get_stats()
	var badge_data = [
		{"type": 0, "condition": stats["words_found"] >= 10},
		{"type": 1, "condition": stats["words_found"] >= 50},
		{"type": 2, "condition": stats["words_found"] >= 100},
		{"type": 3, "condition": stats["words_found"] >= 200},
		{"type": 4, "condition": stats["perfect_games"] >= 1},
		{"type": 5, "condition": stats["perfect_games"] >= 5},
		{"type": 6, "condition": stats_manager.get_accuracy_rate() >= 90},
		{"type": 7, "condition": stats["total_score"] >= 1000},
		{"type": 8, "condition": stats["total_play_time_seconds"] >= 3600},
	]
	
	for data in badge_data:
		var badge = BadgeScene.instantiate()
		badge.set_badge(data["type"], data["condition"])
		badge_container.add_child(badge)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
