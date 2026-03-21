extends Control

# 节点引用
@onready var title_label: Label = $TitleLabel
@onready var main_score_label: Label = $VBoxContainer/MainScoreLabel
@onready var matching_score_label: Label = $VBoxContainer/MatchingScoreLabel
@onready var total_score_label: Label = $VBoxContainer/TotalScoreLabel
@onready var words_found_label: Label = $VBoxContainer/WordsFoundLabel
@onready var time_bonus_label: Label = $VBoxContainer/TimeBonusLabel
@onready var perfect_bonus_label: Label = $VBoxContainer/PerfectBonusLabel
@onready var stats_summary_label: Label = $VBoxContainer/StatsSummaryLabel
@onready var next_game_button: Button = $ButtonContainer/NextGameButton
@onready var main_menu_button: Button = $ButtonContainer/MainMenuButton
@onready var progress_button: Button = $ButtonContainer/ProgressButton


func _ready() -> void:
	_setup_ui()
	_display_results()
	next_game_button.pressed.connect(_on_next_game_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	progress_button.pressed.connect(_on_progress_pressed)


func _setup_ui() -> void:
	title_label.text = "🎉 游戏完成！"


func _display_results() -> void:
	var main_score = GameStateManager.get_last_game_score()
	var matching_score = GameStateManager.get_matching_game_score()
	var total_score = GameStateManager.get_total_score()
	var found_words = GameStateManager.get_last_game_found_words()
	var missed_words = GameStateManager.get_last_game_missed_words()
	var time_remaining = GameStateManager.get_last_game_time_remaining()
	
	# 计算时间奖励
	var time_bonus = int(time_remaining * 0.5)
	
	# 检查是否完美通关
	var is_perfect = missed_words.is_empty()
	var perfect_bonus = 0
	if is_perfect and time_remaining > 90:
		perfect_bonus = 100
	
	main_score_label.text = "网格游戏得分: %d" % main_score
	matching_score_label.text = "连线游戏得分: %d" % matching_score
	time_bonus_label.text = "时间奖励: +%d" % time_bonus
	
	if perfect_bonus > 0:
		perfect_bonus_label.visible = true
		perfect_bonus_label.text = "完美通关奖励: +%d" % perfect_bonus
	else:
		perfect_bonus_label.visible = false
	
	total_score_label.text = "总分: %d" % (total_score + time_bonus + perfect_bonus)
	
	words_found_label.text = "找到单词: %d/%d" % [found_words.size(), found_words.size() + missed_words.size()]
	
	# 更新统计
	StatsManager.complete_game(main_score, is_perfect)
	
	# 统计摘要
	var stats = StatsManager.get_stats()
	stats_summary_label.text = "总游戏次数: %d | 历史最高分: %d | 连胜: %d 局" % [
		stats["total_games"],
		stats["highest_score"],
		stats["win_streak"]
	]


func _on_next_game_pressed() -> void:
	GameStateManager.clear_game_data()
	get_tree().change_scene_to_file("res://scenes/main_2d.tscn")


func _on_main_menu_pressed() -> void:
	GameStateManager.clear_game_data()
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func _on_progress_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/progress_screen.tscn")
