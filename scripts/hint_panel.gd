extends PanelContainer

const HIDDEN_OFFSET: float = 220.0
const VISIBLE_OFFSET: float = -8.0
const ANIMATION_DURATION: float = 0.3

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	offset_bottom = HIDDEN_OFFSET


func _on_mouse_entered() -> void:
	_slide_to_visible()


func _on_mouse_exited() -> void:
	_slide_to_hidden()


func _slide_to_visible() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "offset_bottom", VISIBLE_OFFSET, ANIMATION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _slide_to_hidden() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "offset_bottom", HIDDEN_OFFSET, ANIMATION_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
