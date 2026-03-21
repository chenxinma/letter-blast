extends "res://addons/gut/test.gd"

var UIManagerScript = preload("res://scripts/ui_manager.gd")
var LeitnerManagerScript = preload("res://scripts/leitner_manager.gd")

func test_show_message() -> void:
	var ui_manager = UIManagerScript.new()
	var label = Label.new()
	label.text = ""
	ui_manager.add_child(label)
	ui_manager.found_words_label = label
	
	assert_true(label.text == "", "Initial label should be empty")
	ui_manager.queue_free()

func test_update_ui_with_valid_manager() -> void:
	var ui_manager = UIManagerScript.new()
	var leitner_manager = LeitnerManagerScript.new()
	
	var found_words_label = Label.new()
	
	ui_manager.add_child(found_words_label)
	ui_manager.found_words_label = found_words_label
	ui_manager.leitner_manager = leitner_manager
	
	ui_manager.update_ui()
	
	assert_true(found_words_label.text.begins_with("Found:"), "Should display found words")
	
	ui_manager.queue_free()
	leitner_manager.queue_free()

func test_update_ui_null_check() -> void:
	var ui_manager = UIManagerScript.new()
	
	var found_words_label = Label.new()
	
	ui_manager.add_child(found_words_label)
	ui_manager.found_words_label = found_words_label
	ui_manager.leitner_manager = null
	
	ui_manager.update_ui()
	
	assert_true(found_words_label.text == "", "Should not crash with null leitner_manager")
	
	ui_manager.queue_free()

func _run_tests() -> void:
	_test_show_message()
	_test_update_ui_with_valid_manager()
	_test_update_ui_null_check()
	print("All UIManager tests passed!")