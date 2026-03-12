# 光雨粒子效果实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 在游戏开始场景添加梦幻风格的光雨粒子效果

**Architecture:** 使用 GPUParticles2D 配合 WorldEnvironment 后处理 Glow，粒子使用 GradientTexture2D 作为纹理，颜色设为高亮度 HDR 值触发 Bloom 效果。

**Tech Stack:** Godot 4.6, GPUParticles2D, ProcessMaterial, GradientTexture2D, WorldEnvironment

---

## 任务概览

1. 创建渐变纹理资源
2. 创建粒子材质资源
3. 创建 2D 环境资源
4. 修改 start_screen.tscn 添加粒子节点
5. 验证效果并调整参数

---

### Task 1: 创建渐变纹理资源

**Files:**
- Create: `resources/glow_rain_gradient.tres`

**Step 1: 创建渐变纹理文件**

创建径向渐变纹理，中心高亮白色，边缘透明：

```ini
[gd_resource type="GradientTexture2D" format=3 uid="uid://glowraingrad"]

[resource]
gradient = SubResource("Gradient_abc123")
fill = 1
fill_from = Vector2(0.5, 0.5)
fill_to = Vector2(1, 0.5)

[sub_resource type="Gradient" id="Gradient_abc123"]
interpolation_mode = 2
offsets = PackedFloat32Array(0, 0.3, 1)
colors = PackedColorArray(1, 1, 1, 2, 1, 1, 1, 0.8, 1, 1, 1, 0)
```

**Step 2: 验证文件创建**

在 Godot 编辑器中检查资源是否正确加载。

---

### Task 2: 创建粒子材质资源

**Files:**
- Create: `resources/glow_rain_process_material.tres`

**Step 1: 创建 ProcessMaterial 文件**

配置粒子物理行为：

```ini
[gd_resource type="ParticleProcessMaterial" format=3 uid="uid://glowrainmat"]

[resource]
emission_shape = 3
emission_box_extents = Vector3(960, 10, 1)
direction = Vector3(0, 1, 0)
spread = 15.0
initial_velocity_min = 20.0
initial_velocity_max = 40.0
gravity = Vector3(0, 25, 0)
damping_min = 2.0
damping_max = 3.0
scale_min = 0.1
scale_max = 0.25
color_ramp = SubResource("Gradient_color")

[sub_resource type="Gradient" id="Gradient_color"]
interpolation_mode = 2
offsets = PackedFloat32Array(0, 0.3, 0.7, 1)
colors = PackedColorArray(1, 0.88, 0.4, 1, 1, 0.96, 0.8, 0.9, 1, 0.96, 0.8, 0.5, 1, 1, 1, 0)
```

**Step 2: 验证材质参数**

- 发射形状：Box，宽度覆盖 1920px 屏幕
- 重力向下 25
- 初始速度 20-40，阻尼 2-3 确保缓慢飘落
- 缩放 0.1-0.25，小光点

---

### Task 3: 创建 2D 环境资源

**Files:**
- Create: `resources/start_screen_environment.tres`

**Step 1: 创建 Environment 文件**

配置 Glow 后处理：

```ini
[gd_resource type="Environment" format=3 uid="uid://startscreenenv"]

[resource]
background_mode = 1
background_color = Color(0.1, 0.08, 0.06, 1)
glow_enabled = true
glow_levels/1 = false
glow_levels/2 = true
glow_levels/3 = true
glow_levels/4 = false
glow_levels/5 = false
glow_levels/6 = false
glow_levels/7 = false
glow_intensity = 0.8
glow_strength = 1.0
glow_bloom = 0.5
glow_hdr_threshold = 0.5
glow_hdr_scale = 1.5
glow_bicubic_upscale = true
```

**Step 2: 验证 Glow 配置**

- HDR threshold 0.5 确保高亮度颜色触发发光
- Bloom 0.5 提供柔和的光晕效果

---

### Task 4: 修改 start_screen.tscn

**Files:**
- Modify: `scenes/start_screen.tscn`

**Step 1: 添加外部资源引用**

在文件顶部的 `[ext_resource]` 部分添加：

```ini
[ext_resource type="GradientTexture2D" uid="uid://glowraingrad" path="res://resources/glow_rain_gradient.tres" id="4_gradient"]
[ext_resource type="ParticleProcessMaterial" uid="uid://glowrainmat" path="res://resources/glow_rain_process_material.tres" id="5_particlemat"]
[ext_resource type="Environment" uid="uid://startscreenenv" path="res://resources/start_screen_environment.tres" id="6_env"]
```

**Step 2: 添加 WorldEnvironment 节点**

在 `Background` 节点之后添加：

```ini
[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = ExtResource("6_env")
```

**Step 3: 添加 GPUParticles2D 节点**

在 `WorldEnvironment` 节点之后添加：

```ini
[node name="GlowRain" type="GPUParticles2D" parent="."]
position = Vector2(576, 0)
amount = 40
lifetime = 7.0
explosiveness = 0.0
randomness = 0.3
texture = ExtResource("4_gradient")
process_material = ExtResource("5_particlemat")
```

**Step 4: 调整节点顺序确保层次正确**

确保节点顺序为：
1. StartScreen (Control)
2. Background (TextureRect)
3. WorldEnvironment
4. GlowRain (GPUParticles2D)
5. VBoxContainer (按钮容器)
6. StatusLabel
7. FileDialog
8. Title

---

### Task 5: 验证效果

**Step 1: 在 Godot 编辑器中打开场景**

运行场景，观察光雨效果。

**Step 2: 参数微调建议**

如果效果不理想，可调整：

| 问题 | 解决方案 |
|------|----------|
| 粒子太亮/太暗 | 调整 glow_intensity 或颜色渐变的 HDR 值 |
| 粒子太少/太多 | 调整 amount (30-60) |
| 下落太快/太慢 | 调整 gravity 或 damping |
| 光晕不明显 | 降低 glow_hdr_threshold 或提高 glow_bloom |

**Step 3: 提交更改**

```bash
git add resources/glow_rain_gradient.tres resources/glow_rain_process_material.tres resources/start_screen_environment.tres scenes/start_screen.tscn
git commit -m "feat: add glow rain particle effect to start screen"
```