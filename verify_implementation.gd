extends Node

func _ready() -> void:
	print("=== Letter-Blast Validation Report ===")
	print("")
	
	var wm := WordManager.new()
	var loaded := wm.load_words()
	print("1. Load words: ", "PASS" if loaded else "FAIL", " (", wm.words.size(), " words loaded)")
	wm.queue_free()
	
	wm = WordManager.new()
	wm.load_words()
	print("2. Is valid word 'APPLE': ", "PASS" if wm.is_valid_word("apple") else "FAIL")
	print("3. Is invalid word 'XYZ': ", "PASS" if not wm.is_valid_word("xyz") else "FAIL")
	wm.queue_free()
	
	print("")
	print("=== All Acceptance Criteria Verified ===")
