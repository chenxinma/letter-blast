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
	var leitner_script = load("res://scripts/leitner_manager.gd")
	var leitner_manager = leitner_script.new()
	
	var found_words_label := Label.new()
	
	ui_manager.add_child(found_words_label)
	ui_manager.found_words_label = found_words_label
	ui_manager.leitner_manager = leitner_manager
	
	ui_manager.update_ui()
	
	assert(found_words_label.text.begins_with("Found:"), "Should display found words")
	
	ui_manager.queue_free()
	leitner_manager.queue_free()

func _test_update_ui_null_check() -> void:
	var ui_manager := UIManager.new()
	
	var found_words_label := Label.new()
	
	ui_manager.add_child(found_words_label)
	ui_manager.found_words_label = found_words_label
	ui_manager.leitner_manager = null
	
	ui_manager.update_ui()
	
	assert(found_words_label.text == "", "Should not crash with null leitner_manager")
	
	ui_manager.queue_free()

func _run_tests() -> void:
	_test_show_message()
	_test_update_ui_with_valid_manager()
	_test_update_ui_null_check()
	print("All UIManager tests passed!")