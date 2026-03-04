extends "res://scripts/word_manager.gd"

func _test_load_words() -> void:
	var word_manager := WordManager.new()
	var success := word_manager.load_words()
	assert(success, "load_words should return true")
	assert(word_manager.words.size() == 21, "Should load 21 words")
	assert(word_manager.words.has("APPLE"), "Should have APPLE in dictionary")
	assert(word_manager.words.has("BANANA"), "Should have BANANA in dictionary")
	word_manager.queue_free()

func _test_is_valid_word() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	assert(word_manager.is_valid_word("apple"), "apple should be valid")
	assert(word_manager.is_valid_word("APPLE"), "APPLE should be valid")
	assert(word_manager.is_valid_word("Apple"), "Apple should be valid")
	assert(word_manager.is_valid_word("banana"), "banana should be valid")
	
	assert(not word_manager.is_valid_word("xyz"), "xyz should not be valid")
	assert(not word_manager.is_valid_word(""), "empty string should not be valid")
	
	word_manager.queue_free()

func _test_mark_as_found() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	word_manager.mark_as_found("apple")
	assert(word_manager.found_words.has("APPLE"), "found_words should have APPLE")
	
	word_manager.mark_as_found("banana")
	assert(word_manager.found_words.has("BANANA"), "found_words should have BANANA")
	
	word_manager.mark_as_found("apple")
	assert(word_manager.found_words.size() == 2, "duplicate mark should not increase size")
	
	word_manager.queue_free()

func _test_get_remaining_words() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	var all_remaining := word_manager.get_remaining_words()
	assert(all_remaining.size() == 21, "Should have all 21 words remaining initially")
	
	word_manager.mark_as_found("apple")
	word_manager.mark_as_found("banana")
	
	var remaining := word_manager.get_remaining_words()
	assert(remaining.size() == 19, "Should have 19 words remaining after finding 2")
	assert(not remaining.has("APPLE"), "APPLE should not be in remaining")
	assert(not remaining.has("BANANA"), "BANANA should not be in remaining")
	assert(remaining.has("CHERRY"), "CHERRY should still be in remaining")
	
	word_manager.queue_free()

func _test_reset() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	word_manager.mark_as_found("apple")
	word_manager.mark_as_found("banana")
	assert(word_manager.found_words.size() == 2, "Should have 2 found words")
	
	word_manager.reset()
	assert(word_manager.found_words.size() == 0, "Should have 0 found words after reset")
	assert(word_manager.words.size() == 21, "Words should still be loaded")
	
	word_manager.queue_free()

func _test_load_words_missing_file() -> void:
	var word_manager := WordManager.new()
	var success := word_manager.load_words()
	assert(success == false, "load_words should return false for missing file")
	word_manager.queue_free()

func _test_load_words_invalid_json() -> void:
	var word_manager := WordManager.new()
	var file := FileAccess.open("res://data/invalid_words.json", FileAccess.WRITE)
	if file:
		file.store_string("{ invalid json }")
		file.close()
	var success := word_manager.load_words()
	assert(success == false, "load_words should return false for invalid JSON")
	word_manager.queue_free()

func _run_tests() -> void:
	_test_load_words()
	_test_is_valid_word()
	_test_mark_as_found()
	_test_get_remaining_words()
	_test_reset()
	_test_load_words_missing_file()
	_test_load_words_invalid_json()
	print("All tests passed!")
