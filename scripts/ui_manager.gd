extends CanvasLayer

@onready var word_count_label = $WordCountLabel
@onready var found_words_label = $FoundWordsLabel
@onready var word_manager: WordManager = $WordManager

var _pending_ui_update: bool = false
var _ui_update_queued: bool = false

func _ready() -> void:
	update_ui()

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
	found_words_label.text = message
