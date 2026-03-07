extends "res://scripts/word_manager.gd"

func _test_load_words() -> void:
	var word_manager := WordManager.new()
	var success := word_manager.load_words()
	assert(success, "load_words should return true")
	assert(word_manager.words.size() >= 18, "Should load at least 18 words")
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


func _test_get_chinese() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	assert(word_manager.get_chinese("APPLE") == "苹果", "APPLE should have Chinese meaning")
	assert(word_manager.get_chinese("apple") == "苹果", "apple should have Chinese meaning")
	assert(word_manager.get_chinese("BANANA") == "香蕉", "BANANA should have Chinese meaning")
	assert(word_manager.get_chinese("UNKNOWN") == "", "Unknown word should return empty string")
	
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

func _test_get_level_words() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	var level_words := word_manager.get_level_words(3)
	assert(level_words.size() == 3, "Should get 3 words")
	assert(word_manager.level_words.size() == 3, "level_words should be set")
	
	for word in level_words:
		assert(word_manager.words.has(word), "Level word should be in dictionary")
	
	word_manager.queue_free()

func _test_remaining_words() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	word_manager.get_level_words(3)
	
	var remaining := word_manager.get_remaining_words()
	assert(remaining.size() == 3, "Should have 3 remaining words initially")
	
	word_manager.mark_as_found(word_manager.level_words[0])
	remaining = word_manager.get_remaining_words()
	assert(remaining.size() == 2, "Should have 2 remaining after finding 1")
	
	word_manager.queue_free()

func _test_reset_level() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	word_manager.get_level_words(3)
	
	word_manager.mark_as_found("apple")
	word_manager.mark_as_found("banana")
	assert(word_manager.found_words.size() == 2, "Should have 2 found words")
	
	word_manager.reset_level()
	assert(word_manager.found_words.size() == 0, "Should have 0 found words after reset")
	assert(word_manager.level_words.size() == 3, "level_words should remain")
	
	word_manager.queue_free()

func _test_leitner_boxes() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	assert(word_manager.word_boxes.size() >= 18, "All words should be in box 1 initially")
	
	for word in word_manager.word_boxes:
		assert(word_manager.word_boxes[word] == 1, "Initial box should be 1")
	
	word_manager.queue_free()

func _test_promote_word() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	word_manager.promote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 2, "APPLE should be in box 2")
	
	word_manager.promote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 3, "APPLE should be in box 3")
	
	word_manager.promote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 4, "APPLE should be in box 4")
	
	word_manager.promote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 5, "APPLE should be in box 5")
	
	word_manager.promote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 5, "APPLE should stay in box 5 (max)")
	
	word_manager.queue_free()

func _test_demote_word() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	word_manager.word_boxes["APPLE"] = 3
	word_manager.demote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 2, "APPLE should demote to box 2")
	
	word_manager.demote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 1, "APPLE should demote to box 1")
	
	word_manager.demote_word("APPLE")
	assert(word_manager.word_boxes["APPLE"] == 1, "APPLE should stay in box 1 (min)")
	
	word_manager.queue_free()

func _test_on_level_complete() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	word_manager.get_level_words(3)
	
	word_manager.mark_as_found(word_manager.level_words[0])
	word_manager.mark_as_found(word_manager.level_words[1])
	
	var found_word = word_manager.level_words[0]
	var not_found_word = word_manager.level_words[2]
	
	var found_box_before = word_manager.word_boxes[found_word]
	var not_found_box_before = word_manager.word_boxes[not_found_word]
	
	word_manager.on_level_complete()
	
	assert(word_manager.word_boxes[found_word] == found_box_before + 1, "Found word should be promoted")
	assert(word_manager.word_boxes[not_found_word] == max(1, not_found_box_before - 1), "Not found word should be demoted")
	assert(word_manager.found_words.size() == 0, "found_words should be cleared")
	assert(word_manager.level_words.size() == 0, "level_words should be cleared")
	
	word_manager.queue_free()

func _test_is_word_found() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	assert(not word_manager.is_word_found("apple"), "Should not be found initially")
	
	word_manager.mark_as_found("apple")
	assert(word_manager.is_word_found("apple"), "Should be found after marking")
	
	word_manager.queue_free()

func _test_is_level_word() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	word_manager.get_level_words(3)
	
	assert(word_manager.is_level_word(word_manager.level_words[0]), "First level word should be recognized")
	assert(not word_manager.is_level_word("ZZZZZ"), "Non-level word should not be recognized")
	
	word_manager.queue_free()

func _test_get_box_stats() -> void:
	var word_manager := WordManager.new()
	word_manager.load_words()
	
	var stats = word_manager.get_box_stats()
	assert(stats[1] >= 18, "All words should be in box 1 initially")
	assert(stats[2] == 0, "Box 2 should be empty")
	assert(stats[3] == 0, "Box 3 should be empty")
	assert(stats[4] == 0, "Box 4 should be empty")
	assert(stats[5] == 0, "Box 5 should be empty")
	
	word_manager.promote_word("APPLE")
	stats = word_manager.get_box_stats()
	assert(stats[1] >= 17, "Most words should remain in box 1")
	assert(stats[2] == 1, "1 word should be in box 2")
	
	word_manager.queue_free()

func _run_tests() -> void:
	_test_load_words()
	_test_is_valid_word()
	_test_get_chinese()
	_test_mark_as_found()
	_test_get_level_words()
	_test_remaining_words()
	_test_reset_level()
	_test_leitner_boxes()
	_test_promote_word()
	_test_demote_word()
	_test_on_level_complete()
	_test_is_word_found()
	_test_is_level_word()
	_test_get_box_stats()
	print("All WordManager tests passed!")