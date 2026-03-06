extends Node2D

@onready var word_manager: WordManager = $WordManager
@onready var grid_manager: GridManager = $GridManager
@onready var input_handler: Node = $InputHandler
@onready var level_manager: LevelManager = $LevelManager
@onready var ui_manager: UIManager = $UIManager

var timer_manager: TimerManager
var score_manager: ScoreManager
var story_manager: StoryManager
var hint_manager: HintManager

func _ready() -> void:
	word_manager.load_words()
	grid_manager.word_manager = word_manager
	grid_manager.cell_template = preload("res://scenes/word_cell.tscn")
	
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


func start_new_level() -> void:
	var level = level_manager.current_level
	
	story_manager.current_level = level
	score_manager.set_level(level)
	hint_manager.set_level(level)
	
	level_manager.assign_words()
	grid_manager.word_manager = word_manager
	grid_manager.generate_grid()
	
	var time_limit = 120
	if level <= 3:
		time_limit = 120
	elif level <= 6:
		time_limit = 150
	elif level <= 10:
		time_limit = 180
	else:
		time_limit = 210
	
	timer_manager.start_timer(time_limit)
	ui_manager.update_ui()


func _on_word_validated(word: String, is_valid: bool) -> void:
	if is_valid:
		var _word_score = score_manager.add_score(word, timer_manager.time_remaining)
		word_manager.mark_as_found(word)
		hint_manager.set_remaining_words(word_manager.get_remaining_words())
		hint_manager.set_found_words(word_manager.get_found_words())
		ui_manager.update_ui()


func _on_level_complete() -> void:
	timer_manager.stop_timer()
	
	var level_info = score_manager.complete_level(
		timer_manager.time_remaining, 
		timer_manager.time_limit
	)
	
	print("Level Complete! Score: ", level_info.total)
	
	level_manager.level_complete()
	
	OS.delay_msec(1000)
	start_new_level()


func _on_timer_time_out() -> void:
	print("Time out!")
	timer_manager.stop_timer()
