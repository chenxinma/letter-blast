extends Node2D

@onready var word_manager: WordManager = $WordManager
@onready var grid_manager = $GridManager2D
@onready var input_handler: Node = $InputHandler2D
@onready var level_manager: LevelManager = $LevelManager
@onready var ui_manager: UIManager = $UIManager

var timer_manager: TimerManager
var score_manager: ScoreManager
var story_manager: StoryManager
var hint_manager: HintManager

func _ready() -> void:
	grid_manager.word_manager = word_manager
	grid_manager.cell_template = preload("res://scenes/word_cell_2d.tscn")
	
	input_handler.grid_manager = grid_manager
	input_handler.word_manager = word_manager
	
	level_manager.word_manager = word_manager
	level_manager.grid_manager = grid_manager
	
	setup_managers()
	start_new_level()
	
	input_handler.connect("word_validated", _on_word_validated)
	level_manager.connect("level_completed", _on_level_complete)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			if timer_manager and timer_manager.waiting_to_start:
				timer_manager.begin_timer()
			if ui_manager and not ui_manager.countdown_running:
				ui_manager.start_countdown()
			input_handler.handle_mouse_press(event)
		else:
			input_handler.handle_mouse_release(event)
	elif event is InputEventMouseMotion:
		input_handler.handle_mouse_motion(event)


func setup_managers() -> void:
	timer_manager = TimerManager.new()
	score_manager = ScoreManager.new()
	story_manager = StoryManager.new()
	hint_manager = HintManager.new()
	
	add_child(timer_manager)
	add_child(score_manager)
	add_child(story_manager)
	add_child(hint_manager)
	
	ui_manager.score_manager = score_manager
	ui_manager.timer_manager = timer_manager
	if score_manager:
		score_manager.connect("score_changed", ui_manager._on_score_changed)


func start_new_level() -> void:
	var level = level_manager.current_level
	
	story_manager.current_level = level
	score_manager.set_level(level)
	hint_manager.set_level(level)
	
	word_manager.reset_level()
	
	var config = story_manager.get_level_config(level)
	var word_count = config.get("word_count", 5)
	var time_limit = config.get("time_limit", 120)
	
	word_manager.get_level_words(word_count)
	grid_manager.generate_grid()
	
	timer_manager.start_timer(time_limit)
	ui_manager.reset_countdown()
	ui_manager.update_ui()


func _on_word_validated(word: String, is_valid: bool) -> void:
	if is_valid:
		var word_score = score_manager.add_score(word, timer_manager.time_remaining)
		word_manager.mark_as_found(word)
		hint_manager.set_remaining_words(word_manager.get_remaining_words())
		hint_manager.set_found_words(word_manager.get_found_words())
		ui_manager.show_word_score(word_score)
		ui_manager.update_ui()


func _on_level_complete() -> void:
	timer_manager.stop_timer()
	
	score_manager.complete_level(
		timer_manager.time_remaining, 
		timer_manager.time_limit
	)
	
	print("Level Complete! Score: ", score_manager.total_score)
	
	story_manager.pass_level(level_manager.current_level)
	
	OS.delay_msec(1000)
	start_new_level()