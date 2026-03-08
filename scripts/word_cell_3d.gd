extends Area3D

@onready var letter_label: Label3D = $LetterLabel
@onready var box_mesh: MeshInstance3D = $Box

const CELL_SIZE = 60
const COLOR_HIGHLIGHT = Color(1.0, 0.894, 0.71, 1.0)

const FILL_COLORS: Array[Color] = [
	Color(0.961, 0.902, 0.827),
	Color(0.569, 0.427, 0.357, 1.0),
	Color(0.608, 0.604, 0.357),
	Color(0.863, 0.733, 0.553)
]
const OUTLINE_COLOR: Color = Color(0.545, 0.267, 0.075)
const OUTLINE_COLOR_HIGHLIGHT: Color = Color(0.855, 0.647, 0.125, 1.0)

const USED_COLOR: Color = Color(0.205, 0.205, 0.205, 1.0)
const USED_OUTLINE_COLOR: Color = Color(0.073, 0.073, 0.073, 1.0)

const HOVER_MAX_DISTANCE := 1.5
const HOVER_MAX_RISE := 0.1
const HOVER_SMOOTH_SPEED := 10.0

var letter: String = ""
var _box_color_idx: int = 0
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false
var _target_z: float = 0.0
var _base_z: float = 0.0

func _ready() -> void:
	_setup_sprite()
	_base_z = position.z

func _process(delta: float) -> void:
	var current_z = position.z
	position.z = lerp(current_z, _target_z + _base_z, HOVER_SMOOTH_SPEED * delta)

func _setup_sprite() -> void:
	pass

func set_hint() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if is_used:
		_target_z = 0.0
		return
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query)
	
	var mouse_world_pos: Vector3
	if result:
		mouse_world_pos = result.position
	else:
		var plane = Plane(Vector3.FORWARD, global_position.z)
		mouse_world_pos = plane.intersects_ray(from, to)
		if mouse_world_pos == null:
			mouse_world_pos = global_position
	
	var distance_2d = Vector2(mouse_world_pos.x - global_position.x, mouse_world_pos.y - global_position.y).length()
	var hover_factor = clamp(1.0 - distance_2d / HOVER_MAX_DISTANCE, 0.0, 1.0)
	_target_z = hover_factor * HOVER_MAX_RISE

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	if letter_label and letter.length() == 1:
		letter_label.text = letter.to_upper()
	_apply_random_color()

func set_used() -> void:
	is_used = true
	if is_used:
		if letter_label:
			letter_label.modulate = Color(0.478, 0.478, 0.478, 1.0)
		if box_mesh:
			var material = box_mesh.get_surface_override_material(0)
			if not material:
				return
			material.albedo_color = USED_COLOR
			var outline_material = material.next_pass
			if outline_material and outline_material is ShaderMaterial:
				outline_material.set_shader_parameter("outline_color", 
													  USED_OUTLINE_COLOR)


func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	var material = box_mesh.get_surface_override_material(0)
	if not material:
		return
	
	if highlighted:
		material.albedo_color = COLOR_HIGHLIGHT
		var outline_material = material.next_pass
		if outline_material and outline_material is ShaderMaterial:
			outline_material.set_shader_parameter("outline_color", 
												  OUTLINE_COLOR_HIGHLIGHT)
	else:
		material.albedo_color = FILL_COLORS[_box_color_idx]
		var outline_material = material.next_pass
		if outline_material and outline_material is ShaderMaterial:
			outline_material.set_shader_parameter("outline_color", 
												  OUTLINE_COLOR)


func get_world_position() -> Vector3:
	return global_position

func _apply_random_color() -> void:
	if not box_mesh:
		return
	var material = box_mesh.get_surface_override_material(0)
	if not material:
		return
	var new_material = material.duplicate()
	_box_color_idx = randi() % FILL_COLORS.size()
	var fill_color: Color = FILL_COLORS[_box_color_idx]
	new_material.albedo_color = fill_color
	var outline_material = new_material.next_pass
	if outline_material and outline_material is ShaderMaterial:
		var new_outline = outline_material.duplicate()
		new_outline.set_shader_parameter("outline_color", OUTLINE_COLOR)
		new_material.next_pass = new_outline
	box_mesh.set_surface_override_material(0, new_material)
