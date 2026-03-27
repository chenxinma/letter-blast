extends "res://addons/gut/test.gd"

var LeitnerManagerScript = preload("res://scripts/leitner_manager.gd")
var leitner_manager: Node

func before_each() -> void:
	leitner_manager = LeitnerManagerScript.new()
	add_child(leitner_manager)

func after_each() -> void:
	if leitner_manager:
		leitner_manager.queue_free()

func test_load_default_words() -> void:
	assert_true(leitner_manager.words.size() >= 18, "Should load at least 18 words")
	assert_true(leitner_manager.words.has("APPLE"), "Should have APPLE in dictionary")
	assert_true(leitner_manager.words.has("BANANA"), "Should have BANANA in dictionary")

func test_is_valid_word() -> void:
	assert_true(leitner_manager.is_valid_word("apple"), "apple should be valid")
	assert_true(leitner_manager.is_valid_word("APPLE"), "APPLE should be valid")
	assert_true(leitner_manager.is_valid_word("Apple"), "Apple should be valid")
	assert_true(leitner_manager.is_valid_word("banana"), "banana should be valid")
	
	assert_false(leitner_manager.is_valid_word("xyz"), "xyz should not be valid")
	assert_false(leitner_manager.is_valid_word(""), "empty string should not be valid")

func test_get_chinese() -> void:
	assert_true(leitner_manager.get_chinese("APPLE") == "苹果", "APPLE should have Chinese meaning")
	assert_true(leitner_manager.get_chinese("apple") == "苹果", "apple should have Chinese meaning")
	assert_true(leitner_manager.get_chinese("BANANA") == "香蕉", "BANANA should have Chinese meaning")
	assert_true(leitner_manager.get_chinese("UNKNOWN") == "", "Unknown word should return empty string")

func test_mark_word_found() -> void:
	leitner_manager.mark_word_found("apple")
	assert_true(leitner_manager.is_word_found("apple"), "Should be found after marking")
	
	leitner_manager.mark_word_found("banana")
	assert_true(leitner_manager.is_word_found("banana"), "BANANA should be found")
	
	assert_true(leitner_manager.get_found_words().size() == 2, "Should have 2 found words")

func test_get_words_for_game() -> void:
	var game_words = leitner_manager.get_words_for_game()
	assert_true(game_words.size() == 4, "Should get 4 words by default")
	
	for word in game_words:
		assert_true(leitner_manager.words.has(word), "Game word should be in dictionary")

func test_remaining_words() -> void:
	leitner_manager.get_words_for_game()
	
	var remaining = leitner_manager.get_remaining_words()
	assert_true(remaining.size() == 4, "Should have 4 remaining words initially")
	
	leitner_manager.mark_word_found(leitner_manager.current_game_words[0])
	remaining = leitner_manager.get_remaining_words()
	assert_true(remaining.size() == 3, "Should have 3 remaining after finding 1")

func test_reset_game() -> void:
	leitner_manager.get_words_for_game()
	leitner_manager.mark_word_found("apple")
	leitner_manager.mark_word_found("banana")
	assert_true(leitner_manager.found_words.size() == 2, "Should have 2 found words")
	
	leitner_manager.reset_game()
	assert_true(leitner_manager.found_words.is_empty(), "found_words should be empty after reset")
	assert_true(leitner_manager.current_game_words.is_empty(), "current_game_words should be empty after reset")

func test_is_game_word() -> void:
	leitner_manager.get_words_for_game()
	
	assert_true(leitner_manager.is_game_word(leitner_manager.current_game_words[0]), "First game word should be recognized")
	assert_false(leitner_manager.is_game_word("ZZZZZ"), "Non-game word should not be recognized")

func test_is_game_complete() -> void:
	leitner_manager.get_words_for_game()
	assert_false(leitner_manager.is_game_complete(), "Game should not be complete initially")
	
	for word in leitner_manager.current_game_words:
		leitner_manager.mark_word_found(word)
	
	assert_true(leitner_manager.is_game_complete(), "Game should be complete after finding all words")

func test_get_box_stats() -> void:
	var stats = leitner_manager.get_box_stats()
	assert_true(stats.has(1), "Should have box 1")
	assert_true(stats.has(5), "Should have box 5")

func test_get_current_game_words_info() -> void:
	leitner_manager.get_words_for_game()
	var info = leitner_manager.get_current_game_words_info()
	
	assert_true(info.size() == 4, "Should have info for 4 words")
	
	for word_info in info:
		assert_true(word_info.has("en"), "Should have 'en' field")
		assert_true(word_info.has("zh"), "Should have 'zh' field")

func test_import_words_from_json() -> void:
	var json_content = '{"words": [{"en": "TESTWORD", "zh": "测试词"}]}'
	var result = leitner_manager.import_words_from_json(json_content)
	
	assert_true(result.success, "Import should succeed")
	assert_true(leitner_manager.words.has("TESTWORD"), "TESTWORD should be in dictionary")
	assert_true(leitner_manager.get_chinese("TESTWORD") == "测试词", "TESTWORD should have Chinese meaning")

func test_on_game_complete() -> void:
	leitner_manager.get_words_for_game()
	
	for word in leitner_manager.current_game_words:
		leitner_manager.mark_word_found(word)
	
	leitner_manager.on_game_complete()
	
	assert_true(leitner_manager.found_words.is_empty(), "found_words should be cleared")
	assert_true(leitner_manager.current_game_words.is_empty(), "current_game_words should be cleared")

func test_promote_word() -> void:
	leitner_manager._promote_word("APPLE")
	var box_num = leitner_manager._find_word_box("APPLE")
	assert_true(box_num == 1, "APPLE should be in box 1 after first promotion")

func test_demote_word() -> void:
	leitner_manager._promote_word("APPLE")
	leitner_manager._promote_word("APPLE")
	leitner_manager._demote_word("APPLE")
	
	var box_num = leitner_manager._find_word_box("APPLE")
	assert_true(box_num == 1, "APPLE should be demoted to box 1")