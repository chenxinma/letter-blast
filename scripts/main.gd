extends Node2D

@onready var word_manager: WordManager = $WordManager
@onready var grid_manager: GridManager = $GridManager
@onready var input_handler: Node = $InputHandler
@onready var level_manager: LevelManager = $LevelManager
@onready var ui_manager: UIManager = $UIManager

func _ready() -> void:
	word_manager.load_words()
	grid_manager.word_manager = word_manager
	grid_manager.cell_template = preload("res://scenes/word_cell.tscn")
	grid_manager.generate_grid()
	
	input_handler.grid_manager = grid_manager
	input_handler.word_manager = word_manager
	
	level_manager.word_manager = word_manager
	level_manager.grid_manager = grid_manager
	level_manager.start_level()
	
	input_handler.connect("word_validated", _on_word_validated)
	level_manager.connect("level_complete", ui_manager.update_ui)

func _on_word_validated(word: String, is_valid: bool) -> void:
	if is_valid:
		word_manager.mark_as_found(word)
		ui_manager.update_ui()
