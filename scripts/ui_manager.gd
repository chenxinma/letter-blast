extends CanvasLayer

@onready var word_count_label = $WordCountLabel
@onready var found_words_label = $FoundWordsLabel
@onready var word_manager: WordManager = $WordManager

func _ready() -> void:
	update_ui()

func update_ui() -> void:
	if not word_manager or not word_count_label or not found_words_label:
		return

	var remaining_words = word_manager.get_remaining_words()
	var found_words = word_manager.get_found_words()

	word_count_label.text = "Words left: %d" % remaining_words.size()
	found_words_label.text = "Found: " + String.join(", ", found_words)

func show_message(message: String, duration: float) -> void:
	found_words_label.text = message
