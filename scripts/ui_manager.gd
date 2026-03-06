class_name UIManager

extends CanvasLayer

var word_count_label: Label
var found_words_label: Label
var word_manager: WordManager

func _ready() -> void:
	word_count_label = get_node_or_null("/root/Main/UI/WordCountLabel")
	found_words_label = get_node_or_null("/root/Main/UI/FoundWordsLabel")
	word_manager = get_node_or_null("/root/Main/WordManager")
	update_ui()

func _process(delta: float) -> void:
	pass

func update_ui() -> void:
	if not word_count_label or not found_words_label:
		return

	var remaining_words = word_manager.get_remaining_words() if word_manager else []
	var found_words = word_manager.get_found_words() if word_manager else []

	word_count_label.text = "Words left: %d" % remaining_words.size()
	found_words_label.text = "Found: " + ", ".join(found_words)
