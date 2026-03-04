extends CanvasLayer

@onready var word_count_label = $WordCountLabel
@onready var found_words_label = $FoundWordsLabel
@onready var word_manager: WordManager = $WordManager

var _pending_ui_update: bool = false
var _ui_update_queued: bool = false
var _found_words_cache: String = ""
var _message_duration: float = 0.0
var _showing_message: bool = false

func _ready() -> void:
	update_ui()

func _process(delta: float) -> void:
	if _showing_message and _message_duration > 0:
		_message_duration -= delta
		if _message_duration <= 0:
			_showing_message = false
			found_words_label.text = _found_words_cache

func update_ui() -> void:
	if _ui_update_queued:
		return
	_ui_update_queued = true
	call_deferred("_process_batched_update")

func _process_batched_update() -> void:
	if not word_manager or not word_count_label or not found_words_label:
		_ui_update_queued = false
		return

	var remaining_words = word_manager.get_remaining_words()
	var found_words = word_manager.get_found_words()

	word_count_label.text = "Words left: %d" % remaining_words.size()
	found_words_label.text = "Found: " + String.join(", ", found_words)
	
	_ui_update_queued = false

func show_message(message: String, duration: float) -> void:
	_found_words_cache = found_words_label.text
	_showing_message = true
	_message_duration = duration
	found_words_label.text = message
