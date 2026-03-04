extends "res://scripts/word_cell.gd"

func _test_set_letter() -> void:
	var word_cell := WordCell.new()
	word_cell.set_letter("A", Vector2(0, 0))
	assert(word_cell.letter == "A", "Letter should be A")
	assert(word_cell.coordinate == Vector2(0, 0), "Coordinate should be (0,0)")
	word_cell.queue_free()

func _test_set_used() -> void:
	var word_cell := WordCell.new()
	word_cell.set_letter("B", Vector2(1, 1))
	word_cell.set_used(true)
	assert(word_cell.is_used == true, "Should be used")
	word_cell.set_used(false)
	assert(word_cell.is_used == false, "Should not be used")
	word_cell.queue_free()

func _test_set_highlighted() -> void:
	var word_cell := WordCell.new()
	word_cell.set_letter("C", Vector2(2, 2))
	word_cell.set_highlighted(true)
	assert(word_cell.is_highlighted == true, "Should be highlighted")
	word_cell.set_highlighted(false)
	assert(word_cell.is_highlighted == false, "Should not be highlighted")
	word_cell.queue_free()

func _test_emit_cell_selected() -> void:
	var word_cell := WordCell.new()
	word_cell.set_letter("D", Vector2(3, 3))
	var received = false
	word_cell.cell_selected.connect(func():
		received = true
	)
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = true
	word_cell._on_input_event(mouse_event)
	assert(received, "cell_selected should be emitted")
	word_cell.queue_free()

func _run_tests() -> void:
	_test_set_letter()
	_test_set_used()
	_test_set_highlighted()
	_test_emit_cell_selected()
	print("WordCell tests passed!")
