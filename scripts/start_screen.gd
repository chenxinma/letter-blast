extends Control

const MAIN_SCENE = preload("res://scenes/main_2d.tscn")

@onready var play_button: TextureButton = $VBoxContainer/PlayButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var progress_button: Button = $VBoxContainer/ProgressButton
@onready var file_dialog: FileDialog = $FileDialog
@onready var status_label: Label = $StatusLabel
@onready var click_player: AudioStreamPlayer = $ClickPlayer

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	load_button.pressed.connect(_on_load_pressed)
	progress_button.pressed.connect(_on_progress_pressed)
	file_dialog.file_selected.connect(_on_file_selected)


func _on_play_pressed() -> void:
	if click_player:
		click_player.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(MAIN_SCENE)


func _on_load_pressed() -> void:
	file_dialog.popup_centered(Vector2i(800, 600))


func _on_progress_pressed() -> void:
	if click_player:
		click_player.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/progress_screen.tscn")


func _on_file_selected(path: String) -> void:
	var result = LeitnerManager.import_words_from_file(path)
	
	if result.success:
		status_label.text = "导入成功: 新增 %d 词, 跳过 %d 词" % [result.added, result.skipped]
		status_label.modulate = Color(0.2, 0.8, 0.2)
	else:
		status_label.text = "导入失败: %s" % result.get("error", "未知错误")
		status_label.modulate = Color(0.9, 0.2, 0.2)
