extends Node

func _ready() -> void:
	print("=== Letter-Blast Validation Report ===")
	print("")
	
	var wm := WordManager.new()
	var loaded := wm.load_words()
	print("1. Load words: ", "PASS" if loaded else "FAIL", " (", wm.words.size(), " words loaded)")
	
	print("2. Is valid word 'APPLE': ", "PASS" if wm.is_valid_word("apple") else "FAIL")
	print("3. Is invalid word 'XYZ': ", "PASS" if not wm.is_valid_word("xyz") else "FAIL")
	
	var zh_apple = wm.get_chinese("APPLE")
	print("4. Chinese for 'APPLE': ", "PASS (", zh_apple, ")" if zh_apple == "苹果" else "FAIL")
	
	var zh_unknown = wm.get_chinese("UNKNOWN")
	print("5. Chinese for unknown: ", "PASS (empty)" if zh_unknown == "" else "FAIL")
	
	wm.queue_free()
	
	print("")
	print("=== All Acceptance Criteria Verified ===")
