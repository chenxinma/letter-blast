extends "res://scripts/ui_manager.gd"

func _test_show_message() -> void:
	var ui_manager := UIManager.new()
	var label := Label.new()
	label.text = ""
	ui_manager.add_child(label)
	ui_manager.found_words_label = label
	
	ui_manager.show_message("Test Message", 1.0)
	assert(label.text == "Test Message", "show_message should set label text")
	ui_manager.queue_free()

func _test_update_ui_with_valid_manager() -> void:
	var ui_manager := UIManager.new()
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	var word_count_label := Label.new()
	var found_words_label := Label.new()
	
	ui_manager.add_child(word_count_label)
	ui_manager.add_child(found_words_label)
	ui_manager.word_count_label = word_count_label
	ui_manager.found_words_label = found_words_label
	ui_manager.word_manager = word_manager
	
	ui_manager.update_ui()
	
	assert(word_count_label.text.begins_with("Words left:"), "Should display word count")
	assert(found_words_label.text.begins_with("Found:"), "Should display found words")
	
	ui_manager.queue_free()
	word_manager.queue_free()

func _test_update_ui_null_check() -> void:
	var ui_manager := UIManager.new()
	
	var word_count_label := Label.new()
	var found_words_label := Label.new()
	
	ui_manager.add_child(word_count_label)
	ui_manager.add_child(found_words_label)
	ui_manager.word_count_label = word_count_label
	ui_manager.found_words_label = found_words_label
	ui_manager.word_manager = null
	
	ui_manager.update_ui()
	
	assert(word_count_label.text == "", "Should not crash with null word_manager")
	assert(found_words_label.text == "", "Should not crash with null word_manager")
	
	ui_manager.queue_free()

func _test_get_found_words_method_exists() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	assert(word_manager.has_method("get_found_words"), "WordManager should have get_found_words method")
	
	var found_words = word_manager.get_found_words()
	assert(found_words is Array, "get_found_words should return Array")
	assert(found_words.size() == 0, "Should return empty array initially")
	
	word_manager.queue_free()

func _test_integration_with_word_manager() -> void:
	var ui_manager := UIManager.new()
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	var word_count_label := Label.new()
	var found_words_label := Label.new()
	
	ui_manager.add_child(word_count_label)
	ui_manager.add_child(found_words_label)
	ui_manager.word_count_label = word_count_label
	ui_manager.found_words_label = found_words_label
	ui_manager.word_manager = word_manager
	
	word_manager.mark_as_found("apple")
	word_manager.mark_as_found("banana")
	
	ui_manager.update_ui()
	
	assert(word_count_label.text != "", "Word count should be set")
	assert(found_words_label.text != "", "Found words should be set")
	assert(found_words_label.text.find("APPLE") != -1, "Found words should include APPLE")
	assert(found_words_label.text.find("BANANA") != -1, "Found words should include BANANA")
	
	ui_manager.queue_free()
	word_manager.queue_free()

func _run_tests() -> void:
	_test_show_message()
	_test_update_ui_with_valid_manager()
	_test_update_ui_null_check()
	_test_get_found_words_method_exists()
	_test_integration_with_word_manager()
	print("All UIManager tests passed!")
