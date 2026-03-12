extends Control

const MAIN_SCENE = preload("res://scenes/main_2d.tscn")

@onready var play_button: TextureButton = $VBoxContainer/PlayButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var file_dialog: FileDialog = $FileDialog
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	load_button.pressed.connect(_on_load_pressed)
	file_dialog.file_selected.connect(_on_file_selected)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_SCENE)


func _on_load_pressed() -> void:
	file_dialog.popup_centered(Vector2i(800, 600))


func _on_file_selected(path: String) -> void:
	var word_manager = WordManager.new()
	add_child(word_manager)
	
	var success = word_manager.load_words_from_file(path)
	
	if success:
		status_label.text = "词库加载成功: %s" % path.get_file()
		status_label.modulate = Color(0.2, 0.8, 0.2)
		GlobalWordManager.set_custom_words(word_manager.words, word_manager.word_meanings)
	else:
		status_label.text = "词库加载失败"
		status_label.modulate = Color(0.9, 0.2, 0.2)
	
	word_manager.queue_free()
