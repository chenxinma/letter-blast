extends Area2D

@onready var box_sprite: Sprite2D = $BoxSprite
@onready var letter_sprite: Sprite2D = $LetterSprite
@onready var click_player: AudioStreamPlayer = $ClickPlayer

const BOX_WIDTH := 70
const BOX_HEIGHT := 75
const LETTER_SIZE := 96

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false
var _color_row: int = 0

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	_color_row = randi() % 3
	_update_sprites()

func _update_sprites() -> void:
	if box_sprite:
		var col = 0
		if is_used:
			col = 2
		elif is_highlighted:
			col = 1
		else:
			col = 0
		
		var region = Rect2(col * BOX_WIDTH, _color_row * BOX_HEIGHT, BOX_WIDTH, BOX_HEIGHT)
		box_sprite.region_rect = region
	
	if letter_sprite and letter.length() == 1:
		var letter_idx = letter.to_upper().to_ascii_buffer()[0] - ord('A')
		if letter_idx >= 0 and letter_idx < 26:
			var region = Rect2(letter_idx * LETTER_SIZE, 0, LETTER_SIZE, LETTER_SIZE)
			letter_sprite.region_rect = region
			letter_sprite.visible = true
		else:
			letter_sprite.visible = false

func set_used() -> void:
	is_used = true
	_update_sprites()
	if letter_sprite:
		letter_sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)
		letter_sprite.position.y = 6

func set_highlighted(highlighted: bool) -> void:
	if is_used:
		return
	is_highlighted = highlighted
	if letter_sprite:
		if is_highlighted:
			letter_sprite.position.y -= 5
			if click_player:
				click_player.play()
		else:
			letter_sprite.position.y += 5
	_update_sprites()

func set_hint() -> void:
	pass
