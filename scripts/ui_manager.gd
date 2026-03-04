extends CanvasLayer

@onready var word_count_label = $WordCountLabel
@onready var found_words_label = $FoundWordsLabel

var word_manager: Node

func _ready() -> void:
	word_manager = get_node_or_null("../WordManager")
	update_ui()

func update_ui() -> void:
	if not word_manager:
		word_manager = get_node_or_null("../WordManager")
		if not word_manager:
			return

	var remaining_words = word_manager.get_remaining_words()
	var found_words = word_manager.found_words.keys()

	word_count_label.text = "Words left: %d" % remaining_words.size()
	found_words_label.text = "Found: " + ", ".join(found_words)

func show_message(message: String, duration: float) -> void:
	print("UIManager: ", message)
