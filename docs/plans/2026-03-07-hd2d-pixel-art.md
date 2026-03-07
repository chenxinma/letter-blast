# HD-2D Pixel Art Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Letter-Blast from 2D to HD-2D style using Sprite3D nodes in a 3D environment with lighting and post-processing effects.

**Architecture:** Replace 2D nodes with 3D equivalents (Node3D, Sprite3D, Camera3D), add lighting system and post-processing through WorldEnvironment, implement in 4 phases to maintain stability.

**Tech Stack:** Godot 4.6, Node3D, Sprite3D, Camera3D, DirectionalLight3D, WorldEnvironment, StandardMaterial3D

---

## Phase 1: Basic 3D Scene Setup

### Task 1: Create 3D Main Scene Structure

**Files:**
- Create: `scenes/main_3d.tscn`
- Modify: None (create new scene to preserve 2D version)

**Step 1: Create new 3D scene file**

Create `scenes/main_3d.tscn`:

```gdscript
[gd_scene load_steps=8 format=3 uid="uid://main3d"]

[ext_resource type="Script" path="res://scripts/main_3d.gd" id="1_main"]
[ext_resource type="Script" path="res://scripts/ui_manager.gd" id="2_ui"]
[ext_resource type="Script" path="res://scripts/level_manager.gd" id="3_level"]
[ext_resource type="Script" path="res://scripts/input_handler_3d.gd" id="4_input"]
[ext_resource type="Script" path="res://scripts/grid_manager_3d.gd" id="5_grid"]
[ext_resource type="Script" path="res://scripts/word_manager.gd" id="6_word"]

[node name="Main3D" type="Node3D"]
script = ExtResource("1_main")

[node name="Camera3D" type="Camera3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 0.939693, 0.34202, 0, -0.34202, 0.939693, 0, 5, 10)
projection = 1
fov = 60.0
near = 0.1
far = 1000.0

[node name="UI" type="CanvasLayer" parent="."]

[node name="ScoreLabel" type="Label" parent="UI"]
offset_left = 26.0
offset_top = 19.0
offset_right = 208.0
offset_bottom = 47.0
theme_override_colors/font_color = Color(1, 1, 1, 1)
theme_override_font_sizes/font_size = 20

[node name="FoundWordsLabel" type="Label" parent="UI"]
offset_left = 36.0
offset_top = 477.0
offset_right = 76.0
offset_bottom = 500.0

[node name="WordMeaningsLabel" type="Label" parent="UI"]
offset_left = 831.0
offset_top = 418.0
offset_right = 1131.0
offset_bottom = 768.0
theme_override_colors/font_color = Color(0.9, 0.9, 0.7, 1)
theme_override_font_sizes/font_size = 18
autowrap_mode = 2

[node name="UIManager" type="CanvasLayer" parent="."]
script = ExtResource("2_ui")

[node name="LevelManager" type="Node" parent="."]
script = ExtResource("3_level")

[node name="InputHandler3D" type="Node" parent="."]
script = ExtResource("4_input")

[node name="WordManager" type="Node" parent="."]
script = ExtResource("6_word")

[node name="GridManager3D" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3.5, 0, 0)
script = ExtResource("5_grid")
```

**Step 2: Verify file creation**

Run: `ls scenes/main_3d.tscn`
Expected: File exists

---

### Task 2: Create 3D Main Script

**Files:**
- Create: `scripts/main_3d.gd`

**Step 1: Create 3D main script**

Create `scripts/main_3d.gd`:

```gdscript
extends Node3D

@onready var word_manager: WordManager = $WordManager
@onready var grid_manager: GridManager3D = $GridManager3D
@onready var input_handler: Node = $InputHandler3D
@onready var level_manager: LevelManager = $LevelManager
@onready var ui_manager: UIManager = $UIManager

var timer_manager: TimerManager
var score_manager: ScoreManager
var story_manager: StoryManager
var hint_manager: HintManager

func _ready() -> void:
	grid_manager.word_manager = word_manager
	grid_manager.cell_template = preload("res://scenes/word_cell_3d.tscn")
	
	input_handler.grid_manager = grid_manager
	input_handler.word_manager = word_manager
	
	level_manager.word_manager = word_manager
	level_manager.grid_manager = grid_manager
	
	setup_managers()
	start_new_level()
	
	input_handler.connect("word_validated", _on_word_validated)
	level_manager.connect("level_completed", _on_level_complete)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			if timer_manager and timer_manager.waiting_to_start:
				timer_manager.begin_timer()
			if ui_manager and not ui_manager.countdown_running:
				ui_manager.start_countdown()
			input_handler.handle_mouse_press(event)
		else:
			input_handler.handle_mouse_release(event)
	elif event is InputEventMouseMotion:
		input_handler.handle_mouse_motion(event)


func setup_managers() -> void:
	timer_manager = TimerManager.new()
	score_manager = ScoreManager.new()
	story_manager = StoryManager.new()
	hint_manager = HintManager.new()
	
	add_child(timer_manager)
	add_child(score_manager)
	add_child(story_manager)
	add_child(hint_manager)
	
	ui_manager.score_manager = score_manager
	ui_manager.timer_manager = timer_manager
	if score_manager:
		score_manager.connect("score_changed", ui_manager._on_score_changed)


func start_new_level() -> void:
	var level = level_manager.current_level
	
	story_manager.current_level = level
	score_manager.set_level(level)
	hint_manager.set_level(level)
	
	word_manager.reset_level()
	
	var config = story_manager.get_level_config(level)
	var word_count = config.get("word_count", 5)
	var time_limit = config.get("time_limit", 120)
	
	word_manager.get_level_words(word_count)
	grid_manager.generate_grid()
	
	timer_manager.start_timer(time_limit)
	ui_manager.reset_countdown()
	ui_manager.update_ui()


func _on_word_validated(word: String, is_valid: bool) -> void:
	if is_valid:
		var word_score = score_manager.add_score(word, timer_manager.time_remaining)
		word_manager.mark_as_found(word)
		hint_manager.set_remaining_words(word_manager.get_remaining_words())
		hint_manager.set_found_words(word_manager.get_found_words())
		ui_manager.show_word_score(word_score)
		ui_manager.update_ui()


func _on_level_complete() -> void:
	timer_manager.stop_timer()
	
	var level_info = score_manager.complete_level(
		timer_manager.time_remaining, 
		timer_manager.time_limit
	)
	
	print("Level Complete! Score: ", level_info.total)
	
	story_manager.pass_level(level_manager.current_level)
	
	OS.delay_msec(1000)
	start_new_level()


func _on_timer_time_out() -> void:
	print("Time out!")
	timer_manager.stop_timer()
```

**Step 2: Commit changes**

```bash
git add scripts/main_3d.gd
git commit -m "feat: add 3D main scene script"
```

---

### Task 3: Create 3D Word Cell Scene

**Files:**
- Create: `scenes/word_cell_3d.tscn`

**Step 1: Create 3D word cell scene**

Create `scenes/word_cell_3d.tscn`:

```gdscript
[gd_scene load_steps=3 format=3 uid="uid://wordcell3d"]

[ext_resource type="Script" path="res://scripts/word_cell_3d.gd" id="1_cell"]

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_1"]
transparency = 1
shading_mode = 0
vertex_color_use_as_albedo = true

[node name="WordCell3D" type="Area3D"]
script = ExtResource("1_cell")

[node name="Sprite3D" type="Sprite3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
pixel_size = 0.01
billboard = 1
texture_filter = 0
material_override = SubResource("StandardMaterial3D_1")

[node name="Label3D" type="Label3D" parent="."]
transform = Transform3D(0.1, 0, 0, 0, 0.1, 0, 0, 0, 0.1, 0, 0, 0.1)
pixel_size = 0.01
billboard = 1
text = "A"
font_size = 64
```

**Step 2: Commit**

```bash
git add scenes/word_cell_3d.tscn
git commit -m "feat: add 3D word cell scene"
```

---

### Task 4: Create 3D Word Cell Script

**Files:**
- Create: `scripts/word_cell_3d.gd`

**Step 1: Create 3D word cell script**

Create `scripts/word_cell_3d.gd`:

```gdscript
extends Area3D

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var label_3d: Label3D = $Label3D

const CELL_SIZE = 60
const COLOR_HIGHLIGHT = Color(0.361, 0.486, 0.392, 1.0)
const COLOR_HINT = Color(0.934, 0.837, 0.941, 1.0)
const COLOR_USED = Color(0.5, 0.5, 0.5, 0.5)

var letter: String = ""
var coordinate: Vector2 = Vector2.ZERO
var is_used: bool = false
var is_highlighted: bool = false
var _border_texture_cache: Texture2D

class TextureGenerator:
	static func create_cell_border(size: Vector2) -> ImageTexture:
		var image := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 1, 1, 1))
		
		for x in range(int(size.x)):
			image.set_pixel(x, 0, Color(0, 0, 0, 1))
			image.set_pixel(x, int(size.y) - 1, Color(0, 0, 0, 1))
		
		for y in range(int(size.y)):
			image.set_pixel(0, y, Color(0, 0, 0, 1))
			image.set_pixel(int(size.x) - 1, y, Color(0, 0, 0, 1))
		
		return ImageTexture.create_from_image(image)

func _ready() -> void:
	_setup_sprite()

func _setup_sprite() -> void:
	if not _border_texture_cache:
		_border_texture_cache = TextureGenerator.create_cell_border(Vector2(CELL_SIZE, CELL_SIZE))
	sprite_3d.texture = _border_texture_cache
	sprite_3d.modulate = Color(1.0, 1.0, 1.0, 0.5)

func set_hint() -> void:
	sprite_3d.modulate = COLOR_HINT

func set_letter(c: String, coord: Vector2) -> void:
	letter = c
	coordinate = coord
	if label_3d:
		label_3d.text = letter

func set_used(used: bool) -> void:
	is_used = used
	if is_used:
		modulate = COLOR_USED
		if sprite_3d:
			sprite_3d.modulate = Color(0, 0, 0, 0)
		if label_3d:
			label_3d.modulate = Color(0, 0, 0, 0)
	else:
		modulate = Color(1, 1, 1, 1)
		if sprite_3d:
			if is_highlighted:
				sprite_3d.modulate = COLOR_HIGHLIGHT
			else:
				sprite_3d.modulate = Color(1, 1, 1, 1)
		if label_3d:
			label_3d.modulate = Color(1, 1, 1, 1)

func set_highlighted(highlighted: bool) -> void:
	is_highlighted = highlighted
	if is_used:
		return
	if is_highlighted:
		if sprite_3d:
			sprite_3d.modulate = Color(1, 1, 0, 1)
	elif sprite_3d:
		sprite_3d.modulate = Color(1, 1, 1, 1)

func get_world_position() -> Vector3:
	return global_position
```

**Step 2: Commit**

```bash
git add scripts/word_cell_3d.gd
git commit -m "feat: add 3D word cell script"
```

---

### Task 5: Create 3D Grid Manager

**Files:**
- Create: `scripts/grid_manager_3d.gd`

**Step 1: Create 3D grid manager script**

Create `scripts/grid_manager_3d.gd`:

```gdscript
extends Node3D
class_name GridManager3D

@export var grid_width: int = 10
@export var grid_height: int = 6
@export var cell_spacing: float = 1.0

var word_manager: WordManager
var cell_template: PackedScene
var cells: Dictionary = {}
var selected_cells: Array[Node] = []

const CELL_SIZE_3D = 1.0

func generate_grid() -> void:
	clear_grid()
	
	var grid_data = word_manager.get_grid_data()
	var rows = grid_data.size()
	var cols = grid_data[0].size() if rows > 0 else 0
	
	for y in range(rows):
		for x in range(cols):
			var letter = grid_data[y][x]
			var cell_instance = cell_template.instantiate()
			add_child(cell_instance)
			
			var pos_x = (x - cols / 2.0 + 0.5) * CELL_SIZE_3D * cell_spacing
			var pos_y = (rows / 2.0 - y - 0.5) * CELL_SIZE_3D * cell_spacing
			cell_instance.position = Vector3(pos_x, pos_y, 0)
			
			cell_instance.set_letter(letter, Vector2(x, y))
			cells[Vector2(x, y)] = cell_instance

func clear_grid() -> void:
	for child in get_children():
		child.queue_free()
	cells.clear()
	selected_cells.clear()

func get_cell_at(coord: Vector2) -> Node:
	return cells.get(coord)

func highlight_cell(coord: Vector2, highlight: bool) -> void:
	var cell = get_cell_at(coord)
	if cell:
		cell.set_highlighted(highlight)
		if highlight and not selected_cells.has(cell):
			selected_cells.append(cell)
		elif not highlight and selected_cells.has(cell):
			selected_cells.erase(cell)

func clear_highlights() -> void:
	for cell in selected_cells:
		cell.set_highlighted(false)
	selected_cells.clear()

func get_selected_letters() -> String:
	var result = ""
	for cell in selected_cells:
		result += cell.letter
	return result

func get_selected_coordinates() -> Array[Vector2]:
	var coords: Array[Vector2] = []
	for cell in selected_cells:
		coords.append(cell.coordinate)
	return coords

func mark_used(word_coords: Array) -> void:
	for coord in word_coords:
		var cell = get_cell_at(coord)
		if cell:
			cell.set_used(true)
```

**Step 2: Commit**

```bash
git add scripts/grid_manager_3d.gd
git commit -m "feat: add 3D grid manager"
```

---

### Task 6: Create 3D Input Handler

**Files:**
- Create: `scripts/input_handler_3d.gd`

**Step 1: Create 3D input handler script**

Create `scripts/input_handler_3d.gd`:

```gdscript
extends Node

signal word_validated(word: String, is_valid: bool)

var grid_manager: GridManager3D
var word_manager: WordManager
var is_selecting: bool = false
var selection_start_coord: Vector2 = Vector2(-1, -1)

func handle_mouse_press(event: InputEvent) -> void:
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		is_selecting = true
		selection_start_coord = cell.coordinate
		grid_manager.highlight_cell(cell.coordinate, true)

func handle_mouse_release(event: InputEvent) -> void:
	if not is_selecting:
		return
	
	is_selecting = false
	
	var word = grid_manager.get_selected_letters()
	var coords = grid_manager.get_selected_coordinates()
	
	if word.length() > 0:
		var is_valid = word_manager.is_valid_word(word)
		emit_signal("word_validated", word, is_valid)
		
		if is_valid:
			grid_manager.mark_used(coords)
	
	grid_manager.clear_highlights()
	selection_start_coord = Vector2(-1, -1)

func handle_mouse_motion(event: InputEvent) -> void:
	if not is_selecting:
		return
	
	var mouse_pos = event.position
	var cell = _get_cell_under_mouse(mouse_pos)
	
	if cell:
		var current_coord = cell.coordinate
		if current_coord != selection_start_coord:
			_handle_line_selection(selection_start_coord, current_coord)

func _get_cell_under_mouse(mouse_pos: Vector2) -> Node:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_viewport().world_3d.direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.has("collider"):
		return result["collider"]
	return null

func _handle_line_selection(start: Vector2, end: Vector2) -> void:
	grid_manager.clear_highlights()
	
	var cells_in_line = _get_cells_in_line(start, end)
	for coord in cells_in_line:
		grid_manager.highlight_cell(coord, true)

func _get_cells_in_line(start: Vector2, end: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	
	var dx = int(end.x - start.x)
	var dy = int(end.y - start.y)
	var steps = max(abs(dx), abs(dy))
	
	if steps == 0:
		result.append(start)
		return result
	
	var x_inc = dx / steps
	var y_inc = dy / steps
	
	for i in range(steps + 1):
		var coord = Vector2(int(start.x) + i * x_inc, int(start.y) + i * y_inc)
		result.append(coord)
	
	return result
```

**Step 2: Commit**

```bash
git add scripts/input_handler_3d.gd
git commit -m "feat: add 3D input handler"
```

---

### Task 7: Add Basic Lighting

**Files:**
- Modify: `scenes/main_3d.tscn`

**Step 1: Add directional light to scene**

Edit `scenes/main_3d.tscn`, add after Camera3D node:

```gdscript
[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.433013, 0.25, 0, 0.5, 0.866025, -0.5, -0.75, 0.433013, 0, 10, 0)
light_color = Color(1, 0.95, 0.9, 1)
light_energy = 1.0
shadow_enabled = true
shadow_bias = 0.1
```

**Step 2: Test the scene**

Run: Open Godot editor and run the scene
Expected: Scene loads with 3D grid and lighting

**Step 3: Commit**

```bash
git add scenes/main_3d.tscn
git commit -m "feat: add directional light to 3D scene"
```

---

### Task 8: Update Project Settings

**Files:**
- Modify: `project.godot`

**Step 1: Set main scene to 3D version**

Edit `project.godot`, change line 14:

```gdscript
run/main_scene="res://scenes/main_3d.tscn"
```

**Step 2: Commit**

```bash
git add project.godot
git commit -m "feat: set 3D scene as main scene"
```

---

## Phase 2: Lighting and Shadow System

### Task 9: Add WorldEnvironment

**Files:**
- Modify: `scenes/main_3d.tscn`

**Step 1: Create environment resource**

Create `resources/environment.tres`:

```gdscript
[gd_resource type="Environment" format=3 uid="uid://environment"]

[resource]
background_mode = 1
background_color = Color(0.15, 0.15, 0.2, 1)
ambient_light_source = 2
ambient_light_color = Color(0.3, 0.3, 0.4, 1)
ambient_light_energy = 0.5
```

**Step 2: Add WorldEnvironment to scene**

Edit `scenes/main_3d.tscn`, add after DirectionalLight3D:

```gdscript
[ext_resource type="Environment" path="res://resources/environment.tres" id="env"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = ExtResource("env")
```

**Step 3: Commit**

```bash
git add resources/environment.tres scenes/main_3d.tscn
git commit -m "feat: add WorldEnvironment with ambient lighting"
```

---

### Task 10: Configure Shadow Settings

**Files:**
- Modify: `scenes/main_3d.tscn`

**Step 1: Optimize shadow settings**

Edit the DirectionalLight3D node in `scenes/main_3d.tscn`:

```gdscript
[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.433013, 0.25, 0, 0.5, 0.866025, -0.5, -0.75, 0.433013, 0, 10, 0)
light_color = Color(1, 0.95, 0.9, 1)
light_energy = 1.0
shadow_enabled = true
shadow_bias = 0.05
shadow_reverse_cull_face = true
directional_shadow_max_distance = 50.0
directional_shadow_split_1 = 0.25
directional_shadow_split_2 = 0.5
directional_shadow_split_3 = 0.75
```

**Step 2: Test shadows**

Run: Run the game in Godot editor
Expected: Shadows are visible under word cells

**Step 3: Commit**

```bash
git add scenes/main_3d.tscn
git commit -m "feat: optimize shadow settings for HD-2D effect"
```

---

### Task 11: Add Secondary Light

**Files:**
- Modify: `scenes/main_3d.tscn`

**Step 1: Add fill light**

Edit `scenes/main_3d.tscn`, add after DirectionalLight3D:

```gdscript
[node name="FillLight" type="DirectionalLight3D" parent="."]
transform = Transform3D(-0.5, 0.25, -0.833333, 0, 0.942809, 0.333333, 0.866025, 0.216506, -0.449073, 0, 8, -5)
light_color = Color(0.8, 0.85, 1, 1)
light_energy = 0.3
shadow_enabled = false
```

**Step 2: Test lighting**

Run: Run the game
Expected: Softer, more balanced lighting

**Step 3: Commit**

```bash
git add scenes/main_3d.tscn
git commit -m "feat: add fill light for balanced HD-2D lighting"
```

---

## Phase 3: Post-Processing Effects

### Task 12: Add Depth of Field

**Files:**
- Modify: `resources/environment.tres`

**Step 1: Enable DOF**

Edit `resources/environment.tres`:

```gdscript
[gd_resource type="Environment" format=3 uid="uid://environment"]

[resource]
background_mode = 1
background_color = Color(0.15, 0.15, 0.2, 1)
ambient_light_source = 2
ambient_light_color = Color(0.3, 0.3, 0.4, 1)
ambient_light_energy = 0.5
dof_blur_far_enabled = true
dof_blur_far_distance = 15.0
dof_blur_far_transition = 5.0
dof_blur_near_enabled = false
```

**Step 2: Test DOF**

Run: Run the game
Expected: Background has slight blur

**Step 3: Commit**

```bash
git add resources/environment.tres
git commit -m "feat: add depth of field effect"
```

---

### Task 13: Add Bloom Effect

**Files:**
- Modify: `resources/environment.tres`

**Step 1: Enable bloom**

Edit `resources/environment.tres`, add after DOF settings:

```gdscript
glow_enabled = true
glow_levels/1 = false
glow_levels/2 = true
glow_levels/3 = true
glow_levels/4 = false
glow_levels/5 = false
glow_levels/6 = false
glow_levels/7 = false
glow_intensity = 0.5
glow_strength = 1.0
glow_bloom = 0.3
glow_hdr_threshold = 0.8
glow_hdr_scale = 1.0
glow_bicubic_upscale = true
```

**Step 2: Test bloom**

Run: Run the game
Expected: Soft glow on bright areas

**Step 3: Commit**

```bash
git add resources/environment.tres
git commit -m "feat: add bloom effect for HD-2D style"
```

---

### Task 14: Add Color Correction

**Files:**
- Modify: `resources/environment.tres`

**Step 1: Add color correction**

Edit `resources/environment.tres`, add after glow settings:

```gdscript
adjustment_enabled = true
adjustment_brightness = 1.05
adjustment_contrast = 1.1
adjustment_saturation = 1.15
```

**Step 2: Test color correction**

Run: Run the game
Expected: Slightly more vibrant colors

**Step 3: Commit**

```bash
git add resources/environment.tres
git commit -m "feat: add color correction for enhanced visuals"
```

---

### Task 15: Add Optional Vignette

**Files:**
- Modify: `resources/environment.tres`

**Step 1: Add vignette**

Edit `resources/environment.tres`, add after adjustment settings:

```gdscript
volumetric_fog_enabled = false
```

Note: Godot 4.6 doesn't have built-in vignette, so we'll skip this for now.

**Step 2: Commit current state**

```bash
git add resources/environment.tres
git commit -m "docs: note vignette limitation in Godot 4.6"
```

---

## Phase 4: Optimization and Polish

### Task 16: Add 3D Background

**Files:**
- Create: `scenes/background_3d.tscn`
- Modify: `scenes/main_3d.tscn`

**Step 1: Create background scene**

Create `scenes/background_3d.tscn`:

```gdscript
[gd_scene format=3 uid="uid://background3d"]

[node name="Background3D" type="Node3D"]

[node name="Floor" type="MeshInstance3D" parent="."]
transform = Transform3D(20, 0, 0, 0, 1, 0, 0, 0, 30, 0, -1, 0)
mesh = PlaneMesh(20, 30)

[node name="Background" type="Sprite3D" parent="."]
transform = Transform3D(30, 0, 0, 0, 20, 0, 0, 0, 1, 0, 10, -15)
pixel_size = 0.01
billboard = 0
texture_filter = 0
```

**Step 2: Add background to main scene**

Edit `scenes/main_3d.tscn`, add as first child of Main3D:

```gdscript
[ext_resource type="PackedScene" path="res://scenes/background_3d.tscn" id="bg"]

[node name="Background3D" parent="." instance=ExtResource("bg")]
```

**Step 3: Commit**

```bash
git add scenes/background_3d.tscn scenes/main_3d.tscn
git commit -m "feat: add 3D background and floor"
```

---

### Task 17: Optimize Sprite3D Settings

**Files:**
- Modify: `scenes/word_cell_3d.tscn`

**Step 1: Optimize texture filtering**

Edit `scenes/word_cell_3d.tscn`, modify Sprite3D node:

```gdscript
[node name="Sprite3D" type="Sprite3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
pixel_size = 0.005
billboard = 1
texture_filter = 0
material_override = SubResource("StandardMaterial3D_1")
```

**Step 2: Test visual quality**

Run: Run the game
Expected: Crisp pixel art without blur

**Step 3: Commit**

```bash
git add scenes/word_cell_3d.tscn
git commit -m "feat: optimize Sprite3D for crisp pixel rendering"
```

---

### Task 18: Add Camera Animation

**Files:**
- Modify: `scripts/main_3d.gd`

**Step 1: Add subtle camera sway**

Edit `scripts/main_3d.gd`, add after `extends Node3D`:

```gdscript
@onready var camera: Camera3D = $Camera3D

var camera_initial_position: Vector3
var time_elapsed: float = 0.0
var camera_sway_enabled: bool = true
var sway_amplitude: float = 0.02
var sway_speed: float = 0.5
```

Add in `_ready()` after existing code:

```gdscript
camera_initial_position = camera.position
```

Add new function:

```gdscript
func _process(delta: float) -> void:
	if camera_sway_enabled and camera:
		time_elapsed += delta
		var sway_offset = Vector3(
			sin(time_elapsed * sway_speed * 1.3) * sway_amplitude,
			sin(time_elapsed * sway_speed) * sway_amplitude,
			0
		)
		camera.position = camera_initial_position + sway_offset
```

**Step 2: Test camera animation**

Run: Run the game
Expected: Subtle camera movement for dynamic feel

**Step 3: Commit**

```bash
git add scripts/main_3d.gd
git commit -m "feat: add subtle camera sway for HD-2D effect"
```

---

### Task 19: Performance Testing

**Files:**
- None (testing task)

**Step 1: Test performance**

Run: Run the game in release mode with FPS counter
Expected: Consistent 60+ FPS

**Step 2: Monitor performance**

- Open Godot profiler
- Play for 2-3 minutes
- Check for frame drops or memory leaks

**Step 3: Document performance**

Create `docs/performance_results.md`:

```markdown
# HD-2D Performance Results

**Date:** 2026-03-07
**Platform:** PC Desktop
**Godot Version:** 4.6

## Results

- Average FPS: [Record actual FPS]
- Memory Usage: [Record memory]
- Frame Time: [Record frame time]

## Observations

- [Note any performance issues]
- [Note any visual artifacts]
- [Note any bugs]

## Next Steps

- [If performance issues, list optimization tasks]
```

**Step 4: Commit**

```bash
git add docs/performance_results.md
git commit -m "docs: add performance testing results"
```

---

### Task 20: Final Testing and Bug Fixes

**Files:**
- All modified files

**Step 1: Comprehensive testing**

Test checklist:
- [ ] Game loads correctly
- [ ] Word grid displays properly
- [ ] Mouse selection works
- [ ] Word validation works
- [ ] Score updates correctly
- [ ] Level progression works
- [ ] No visual artifacts
- [ ] No console errors

**Step 2: Fix any issues found**

If issues found, create bug fix commits:

```bash
git add [files]
git commit -m "fix: [description of fix]"
```

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: complete HD-2D pixel art implementation

- Converted 2D scene to 3D with Sprite3D nodes
- Added lighting and shadow system
- Implemented post-processing effects (DOF, bloom, color correction)
- Added camera animation
- Optimized performance for 60 FPS

Closes #HD2D-implementation"
```

---

## Summary

This plan implements HD-2D pixel art style in 4 phases:
1. **Phase 1:** Basic 3D scene setup (Tasks 1-8)
2. **Phase 2:** Lighting and shadows (Tasks 9-11)
3. **Phase 3:** Post-processing effects (Tasks 12-15)
4. **Phase 4:** Optimization and polish (Tasks 16-20)

Each task follows TDD principles where applicable, with frequent commits for easy rollback.

**Estimated time:** 5-7 days for complete implementation