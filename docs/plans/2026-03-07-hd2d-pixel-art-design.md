# HD-2D像素风效果设计文档

**日期：** 2026-03-07  
**项目：** Letter-Blast  
**目标：** 实现类似《八方旅人》的HD-2D像素风效果

## 概述

将Letter-Blast游戏从纯2D转换为HD-2D风格，使用Sprite3D节点在3D空间中渲染2D像素精灵，配合3D环境、光照系统和后处理效果，创造具有深度感的视觉体验。

## 设计目标

### 核心目标
- 保持现有2D像素艺术风格
- 添加3D深度和立体感
- 实现动态光照和阴影
- 添加景深、光晕等后处理效果
- 分阶段实施，降低风险

### 成功标准
- 文字格子具有明显的立体感和深度
- 光照效果增强游戏氛围
- 性能保持在60FPS以上（PC平台）
- 现有游戏逻辑不受影响

## 技术方案

### 架构设计

#### 场景结构
```
Main (Node3D)
├── WorldEnvironment
│   └── Environment (后处理配置)
├── DirectionalLight3D (主光源)
├── Camera3D
├── Floor (MeshInstance3D - 地面)
├── Background (Sprite3D - 背景层)
└── GridContainer3D
    └── WordCell (Sprite3D) x N
```

#### 核心组件

**1. Sprite3D节点**
- 用于在3D空间渲染2D像素精灵
- 设置 `billboard` 模式让精灵始终朝向摄像机
- 配置 `shaded` 属性启用光照
- 调整 `pixel_size` 保持像素清晰度

**2. 3D光照系统**
- DirectionalLight3D：主光源，模拟日光
- PointLight3D：局部光源，用于特效
- 配置阴影：增强立体感

**3. 后处理效果**
- 景深（Depth of Field）：聚焦前景，虚化背景
- 光晕（Bloom）：高光溢出效果
- 色差（Chromatic Aberration）：复古像素感
- 边缘检测：可选，增强轮廓

**4. 摄像机系统**
- Camera3D：透视投影
- 调整FOV：控制视角深度
- 摄像机动画：轻微晃动增加动感

### 分阶段实施计划

#### 阶段1：基础3D场景搭建（1-2天）
- 创建3D主场景
- 配置Camera3D和基础光照
- 将WordCell转换为Sprite3D
- 搭建简单的3D地面和背景

**验收标准：**
- 游戏可运行，文字格子显示正常
- 具有基本的3D透视效果

#### 阶段2：光照和阴影系统（1-2天）
- 完善主光源配置
- 添加阴影系统
- 调整Sprite3D的光照属性
- 优化光照参数

**验收标准：**
- 文字格子有明显阴影
- 光照增强立体感
- 性能保持60FPS

#### 阶段3：后处理效果（1天）
- 配置WorldEnvironment
- 添加景深效果
- 添加光晕效果
- 微调后处理参数

**验收标准：**
- 视觉效果接近HD-2D风格
- 后处理不影响可读性

#### 阶段4：优化和打磨（1天）
- 性能优化
- 视觉细节调整
- 添加动态效果（可选）
- 测试和修复bug

**验收标准：**
- 性能稳定
- 视觉效果满意
- 无明显bug

## 技术细节

### Sprite3D配置
```gdscript
# 像素大小计算
var pixel_size = 0.01  # 根据实际调整

# 光照配置
material_override = StandardMaterial3D.new()
material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # 或 PER_PIXEL
material_override.vertex_color_use_as_albedo = true
```

### 摄像机配置
```gdscript
# 透视投影
projection = Camera3D.PROJECTION_PERSPECTIVE
fov = 60  # 视场角
near = 0.1
far = 1000

# 位置和旋转
position = Vector3(0, 5, 10)
rotation_degrees = Vector3(-20, 0, 0)
```

### 光照配置
```gdscript
# 主光源
light_color = Color(1.0, 0.95, 0.9)  # 暖色调
light_energy = 1.0
shadow_enabled = true
shadow_bias = 0.1
```

### 后处理配置
```gdscript
# Environment资源
environment.background_mode = Environment.BG_CLEAR_COLOR
environment.dof_blur_far_enabled = true
environment.dof_blur_far_distance = 20.0
environment.glow_enabled = true
environment.glow_intensity = 0.5
```

## 风险和缓解

### 风险1：性能问题
**缓解措施：**
- 分阶段实施，每阶段测试性能
- 使用LOD（细节层次）优化远处物体
- 限制阴影距离和分辨率

### 风险2：文字可读性下降
**缓解措施：**
- 调整摄像机角度和距离
- 优化光照强度
- 确保文字格子有足够对比度

### 风险3：现有逻辑破坏
**缓解措施：**
- 保持游戏逻辑脚本不变
- 只修改场景结构和渲染节点
- 充分测试游戏功能

## 资源需求

### 美术资源
- 现有2D像素图可继续使用
- 可能需要制作3D地面和背景模型
- 可选：制作粒子特效

### 技术资源
- Godot 4.6（已具备）
- 无需额外插件

## 后续扩展

### 可选增强功能
- 动态光照效果（日夜变化）
- 粒子系统（文字消除特效）
- 摄像机动画（胜利时拉近）
- 环境音效配合视觉效果

## 参考资料

- Godot官方文档：Sprite3D, Camera3D, WorldEnvironment
- 《八方旅人》视觉分析
- HD-2D技术实现案例

---

**下一步：** 调用writing-plans技能创建详细实施计划