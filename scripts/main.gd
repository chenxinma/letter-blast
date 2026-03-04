extends Node2D

@onready var word_manager: Node = $WordManager
@onready var grid_manager: Node2D = $GridManager
@onready var input_handler: Node = $InputHandler
@onready var level_manager: Node = $LevelManager
@onready var ui_manager: CanvasLayer = $UIManager

func _ready() -> void:
	word_manager.connect("word_found", ui_manager, "on_word_found")
	word_manager.connect("game_over", ui_manager, "on_game_over")
	level_manager.connect("level_changed", ui_manager, "on_level_changed")
	input_handler.connect("input_processed", word_manager, "process_input")
