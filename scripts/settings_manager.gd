extends Node

const SETTINGS_FILE = "user://settings.json"

# 提示模式枚举
const HintMode = {
	BOTH = 0,      # 中英文模式（默认）
	ZH_ONLY = 1,   # 仅中文模式
	EN_ONLY = 2    # 仅英文模式
}

var current_hint_mode: int = HintMode.BOTH
var sound_enabled: bool = true
var music_enabled: bool = true

signal hint_mode_changed(mode: int)
signal settings_loaded


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		print("SettingsManager: No settings file found, using defaults")
		_save_default_settings()
		return
	
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if data is Dictionary:
			if data.has("hint_mode"):
				var mode_str = data["hint_mode"]
				current_hint_mode = _string_to_hint_mode(mode_str)
			if data.has("sound_enabled"):
				sound_enabled = data["sound_enabled"]
			if data.has("music_enabled"):
				music_enabled = data["music_enabled"]
			print("SettingsManager: Settings loaded, hint_mode = ", _hint_mode_to_string(current_hint_mode))
	else:
		print("SettingsManager: Failed to parse settings, using defaults")
		_save_default_settings()
	
	emit_signal("settings_loaded")


func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if not file:
		print("SettingsManager: ERROR - Failed to save settings")
		return
	
	var save_data = {
		"hint_mode": _hint_mode_to_string(current_hint_mode),
		"sound_enabled": sound_enabled,
		"music_enabled": music_enabled
	}
	
	var json_str = JSON.stringify(save_data, "  ")
	file.store_string(json_str)
	file.close()
	print("SettingsManager: Settings saved")


func _save_default_settings() -> void:
	current_hint_mode = HintMode.BOTH
	sound_enabled = true
	music_enabled = true
	save_settings()


func set_hint_mode(mode: int) -> void:
	if mode != current_hint_mode:
		current_hint_mode = mode
		save_settings()
		emit_signal("hint_mode_changed", mode)
		print("SettingsManager: Hint mode changed to ", _hint_mode_to_string(mode))


func get_hint_mode() -> int:
	return current_hint_mode


func get_hint_mode_string() -> String:
	return _hint_mode_to_string(current_hint_mode)


func _hint_mode_to_string(mode: int) -> String:
	match mode:
		0:
			return "both"
		1:
			return "zh_only"
		2:
			return "en_only"
		_:
			return "both"


func _string_to_hint_mode(mode_str: String) -> int:
	match mode_str:
		"both":
			return 0
		"zh_only":
			return 1
		"en_only":
			return 2
		_:
			return 0


func get_display_text_for_word(en_word: String, zh_meaning: String) -> String:
	match current_hint_mode:
		0:
			return "%s (%s)" % [en_word, zh_meaning]
		1:
			return zh_meaning
		2:
			return en_word
		_:
			return "%s (%s)" % [en_word, zh_meaning]


func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	save_settings()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	save_settings()
