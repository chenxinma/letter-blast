class_name TimerManager

extends Node

var time_remaining: int = 0
var is_running: bool = false
var time_limit: int = 120
var waiting_to_start: bool = false

signal time_changed(seconds: int)
signal time_out()

func _ready() -> void:
	pass


func start_timer(seconds: int) -> void:
	time_limit = seconds
	time_remaining = seconds
	waiting_to_start = true
	is_running = false
	emit_signal("time_changed", time_remaining)


func begin_timer() -> void:
	if waiting_to_start:
		waiting_to_start = false
		is_running = true


func stop_timer() -> void:
	is_running = false


func pause_timer() -> void:
	is_running = false


func resume_timer() -> void:
	is_running = true


func _process(delta: float) -> void:
	if is_running and time_remaining > 0:
		time_remaining -= int(delta)
		if time_remaining <= 0:
			time_remaining = 0
			is_running = false
			time_out.emit()
		emit_signal("time_changed", time_remaining)


func get_elapsed_time() -> int:
	return time_limit - time_remaining


func get_time_percent() -> float:
	if time_limit == 0:
		return 0.0
	return float(time_remaining) / float(time_limit)


func reset() -> void:
	stop_timer()
	time_remaining = 0


func add_time(seconds: int) -> void:
	time_remaining = clamp(time_remaining + seconds, 0, time_limit)
	emit_signal("time_changed", time_remaining)
