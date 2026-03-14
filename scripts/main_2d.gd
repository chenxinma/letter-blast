extends Node2D

const LeitnerManagerScript = preload("res://scripts/leitner_manager.gd")

@onready var grid_manager = $GridManager2D
@onready var input_handler: Node = $InputHandler2D
@onready var ui_manager: UIManager = $UIManager
@onready var close_button: Button = $"UI/CloseButton"
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

var leitner_manager: Node
var timer_manager: TimerManager
var score_manager: ScoreManager
var hint_manager: HintManager

const TIME_LIMIT: int = 180


func _ready() -> void:
	grid_manager.cell_template = preload("res://scenes/word_cell_2d.tscn")
	
	input_handler.grid_manager = grid_manager
	
	setup_managers()
	start_new_game()
	
	input_handler.connect("word_validated", _on_word_validated)
	leitner_manager.connect("game_completed", _on_game_completed)
	close_button.connect("pressed", _on_close_button_pressed)
	bgm_player.connect("finished", _on_bgm_finished)


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
	leitner_manager = LeitnerManagerScript.new()
	timer_manager = TimerManager.new()
	score_manager = ScoreManager.new()
	hint_manager = HintManager.new()
	
	add_child(leitner_manager)
	add_child(timer_manager)
	add_child(score_manager)
	add_child(hint_manager)
	
	input_handler.leitner_manager = leitner_manager
	ui_manager.leitner_manager = leitner_manager
	ui_manager.timer_manager = timer_manager
	ui_manager.score_manager = score_manager
	
	if score_manager:
		score_manager.connect("score_changed", ui_manager._on_score_changed)


func start_new_game() -> void:
	score_manager.reset_level()
	leitner_manager.reset_game()
	
	var game_words = leitner_manager.get_words_for_game()
	print("Main: Starting new game with words: ", game_words)
	
	grid_manager.set_game_words(game_words)
	grid_manager.generate_grid()
	
	timer_manager.start_timer(TIME_LIMIT)
	ui_manager.reset_countdown()
	ui_manager.update_ui()


func _on_word_validated(word: String, is_valid: bool) -> void:
	if is_valid and leitner_manager.is_game_word(word):
		var word_score = score_manager.add_score(word, timer_manager.time_remaining)
		leitner_manager.mark_word_found(word)
		hint_manager.set_remaining_words(leitner_manager.get_remaining_words())
		hint_manager.set_found_words(leitner_manager.get_found_words())
		ui_manager.show_word_score(word_score)
		ui_manager.update_ui()
		
		if leitner_manager.is_game_complete():
			_on_game_complete()


func _on_game_complete() -> void:
	timer_manager.stop_timer()
	
	score_manager.complete_level(
		timer_manager.time_remaining, 
		timer_manager.time_limit
	)
	
	leitner_manager.update_score(score_manager.total_score)
	leitner_manager.on_game_complete()
	
	print("Game Complete! Total Score: ", score_manager.total_score)
	
	ui_manager.update_ui()
	
	await get_tree().create_timer(2.0).timeout
	start_new_game()


func _on_game_completed(words_found: Array, words_missed: Array) -> void:
	print("Game completed - Found: ", words_found, " Missed: ", words_missed)


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func _on_bgm_finished() -> void:
	bgm_player.play()
