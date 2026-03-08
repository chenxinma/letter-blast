# Letter Blast 系统设计文档

## 概述

Letter Blast 是一款基于 Godot 4 的 3D 单词拼写游戏。玩家通过在网格中拖拽选择字母来拼写单词，游戏结合了艾宾浩斯记忆曲线进行词汇学习。

---

## 模块架构

```
Main3D (主控制器)
├── GridManager3D      # 网格管理
├── InputHandler3D     # 输入处理
├── WordManager        # 单词管理
├── LevelManager       # 关卡管理
├── UIManager          # UI显示
├── ScoreManager       # 分数管理
├── TimerManager       # 计时管理
├── HintManager        # 提示管理
└── StoryManager       # 故事/配置管理
```

---

## 1. 网格系统 (GridManager3D)

### 1.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `grid_width` | int | 网格宽度 (默认 18) |
| `grid_height` | int | 网格高度 (默认 4) |
| `cell_spacing` | float | 单元格间距 (默认 0.35) |
| `cells` | Dictionary | 坐标 → 单元格实例映射 |
| `selected_cells` | Array[Node] | 当前选中的单元格 |
| `placed_paths` | Dictionary | 单词 → 放置路径映射 |

### 1.2 单元格坐标系统

- 坐标原点：左上角 (0, 0)
- X 轴：向右递增
- Y 轴：向下递增

```
(0,0) (1,0) (2,0) ... (17,0)
(0,1) (1,1) (2,1) ... (17,1)
(0,2) (1,2) (2,2) ... (17,2)
(0,3) (1,3) (2,3) ... (17,3)
```

### 1.3 单词放置算法

**核心流程：**

```
generate_grid()
    ├── 清空网格和放置记录
    ├── 初始化所有坐标为 null
    ├── 遍历关卡单词 → place_word_in_grid()
    └── 填充空白位置 → 随机字母
```

**单词放置逻辑 (place_word_in_grid)：**

1. 随机选择起始位置
2. 验证首字母是否可放置
3. 递归尝试构建路径 (`try_place_word_recursive`)
4. 路径限制：最大 30 步递归深度
5. 方向限制：上下左右四个方向，禁止原路返回

**路径选择规则：**

```
可用方向 = 四方向 - 反向 - 已访问坐标 - 越界坐标
每次尝试时打乱方向顺序 (shuffle)
```

**字母冲突处理：**

- 空位 → 允许放置
- 已占用且字母匹配 → 允许共享
- 已占用且字母不匹配 → 拒绝

### 1.4 3D位置计算

```gdscript
pos_x = (col - grid_width/2.0 + 0.5) * CELL_SIZE_3D * cell_spacing
pos_y = (grid_height/2.0 - row - 0.5) * CELL_SIZE_3D * cell_spacing
```

---

## 2. 输入系统 (InputHandler3D)

### 2.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `selected_path` | Array[Vector2] | 选中的坐标路径 |
| `current_word` | String | 当前拼写的单词 |

### 2.2 事件处理流程

```
鼠标按下 (handle_mouse_press)
    └── 射线检测单元格 → select_cell()

鼠标移动 (handle_mouse_motion)
    └── 左键按下时 → 射线检测 → select_cell()

鼠标释放 (handle_mouse_release)
    ├── 路径长度 >= 2 → validate_word()
    └── 否则 → clear_selection()
```

### 2.3 射线检测

```gdscript
# 3D射线投射参数
query.collide_with_areas = true
query.collide_with_bodies = false
query.collision_mask = 2  # Layer 2
```

### 2.4 选择规则

**邻接判定：**

```gdscript
# 允许的相邻关系
(dx == 1 && dy == 0) ||  # 水平相邻
(dx == 0 && dy == 1) ||  # 垂直相邻
(dx == 1 && dy == 1)     # 对角相邻
```

**选择条件：**

1. 坐标有效
2. 单元格存在且未使用
3. 与上一个选中格相邻
4. 未重复选择同一格

### 2.5 单词验证

```
validate_word()
    ├── 长度 >= 2
    ├── word_manager.is_valid_word() → 有效
    │   ├── grid_manager.mark_used() → 标记已使用
    │   ├── word_manager.mark_as_found() → 记录已找到
    │   └── emit_signal("word_validated", word, true)
    └── 无效 → emit_signal("word_validated", word, false)
```

---

## 3. 分数系统 (ScoreManager)

### 3.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `total_score` | int | 总分数 |
| `level_score` | int | 当前关卡分数 |
| `found_words` | Array | 已找到的单词 |
| `current_level` | int | 当前关卡 |

### 3.2 分数计算规则

**单词基础分：**

| 单词长度 | 基础分 | 难度倍率 | 最终分数 |
|----------|--------|----------|----------|
| ≤3 | 10 | 1.0x | 10 |
| 4-5 | 20 | 1.5x | 30 |
| 6-7 | 40 | 2.0x | 80 |
| ≥8 | 80 | 3.0x | 240 |

**时间奖励：**

```gdscript
time_bonus = int(time_remaining * 0.5)
```

**完美奖励：**

```gdscript
# 剩余时间超过50%时获得
if time_remaining / time_limit > 0.5:
    perfect_bonus = 100
```

### 3.3 信号机制

| 信号 | 参数 | 触发时机 |
|------|------|----------|
| `score_changed` | new_score: int | 分数变化时 |
| `level_complete` | score, time_bonus, total | 关卡完成时 |

---

## 4. 提示系统 (HintManager)

### 4.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `hints_left` | int | 剩余提示次数 |
| `MAX_HINTS_PER_LEVEL` | const | 每关最多3次提示 |
| `remaining_words` | Array | 未找到的单词 |
| `found_words` | Array | 已找到的单词 |

### 4.2 提示类型

**1. 单词揭示 (use_hint)**

```gdscript
返回: {
    "success": bool,
    "word": String,      # 完整单词
    "hints_left": int
}
```

**2. 首字母提示 (use_letter_hint)**

```gdscript
返回: {
    "success": bool,
    "letter": String,    # 首字母
    "word": String,
    "hints_left": int
}
```

### 4.3 提示状态管理

```
set_level(level_num)
    └── 重置 hints_left = MAX_HINTS_PER_LEVEL

set_remaining_words(words)
    └── 更新未找到单词列表

can_use_hint()
    └── hints_left > 0 && remaining_words不为空
```

### 4.4 提示单元格显示

单元格被标记为提示时：

```gdscript
# WordCell3D 颜色
COLOR_HINT = Color(0.643, 0.349, 0.671, 0.5)  # 紫色半透明
```

---

## 5. UI显示系统 (UIManager)

### 5.1 UI元素

| 元素 | 功能 |
|------|------|
| ScoreLabel | 显示分数和倒计时 |
| FoundWordsLabel | 已找到的单词列表 |
| WordMeaningsLabel | 本关单词及释义 |

### 5.2 显示逻辑

**分数显示：**

```
正常: "Score: {total} ({countdown}s)"
得分后: "Score: {total} (+{word_score})"  # 显示1.5秒
```

**单词列表显示：**

```
本关单词:
[✓] APPLE - 苹果
[ ] BANANA - 香蕉
```

### 5.3 倒计时机制

- 每关固定倒计时 30 秒
- 首次点击开始倒计时
- 倒计时结束触发 `countdown_finished` 信号

---

## 6. 单元格系统 (WordCell3D)

### 6.1 状态颜色

| 状态 | 颜色 | RGBA |
|------|------|------|
| 普通 | 白色半透明 | (1.0, 1.0, 1.0, 0.5) |
| 提示 | 紫色半透明 | (0.643, 0.349, 0.671, 0.5) |
| 选中 | 黄色 | (1.0, 1.0, 0, 1.0) |
| 已使用 | 透明 | (0, 0, 0, 0) |

### 6.2 组件结构

```
WordCell3D (Area3D)
├── Sprite3D    # 边框纹理
└── Label3D     # 字母显示
```

---

## 7. 事件流程图

### 7.1 玩家选择单词流程

```
用户点击单元格
    │
    ▼
InputHandler.handle_mouse_press()
    │
    ▼
select_cell() → 验证邻接性
    │
    ▼
单元格高亮 + 路径记录
    │
    ▼
用户释放鼠标
    │
    ▼
validate_word() → WordManager验证
    │
    ├── 有效 → mark_used() → 更新分数
    │   │
    │   └── ScoreManager.add_score()
    │       │
    │       └── emit "score_changed"
    │
    └── 无效 → clear_selection()
```

### 7.2 关卡完成流程

```
WordManager.mark_as_found()
    │
    ▼
LevelManager.check_level_complete()
    │
    ├── 剩余单词为空
    │   │
    │   ▼
    │   level_complete()
    │       │
    │       ├── ScoreManager.complete_level()
    │       ├── WordManager.on_level_complete()
    │       │   └── 艾宾浩斯升降级
    │       └── emit "level_completed"
    │
    └── 继续
```

---

## 8. 艾宾浩斯记忆系统

### 8.1 单词盒子机制

```
Box 1 (新词) → Box 2 → Box 3 → Box 4 → Box 5 (熟练)
     ↑_________________________↓
            遗忘降级
```

### 8.2 升降级规则

| 关卡结果 | 操作 |
|----------|------|
| 单词找到 | 升一级 (最高Box 5) |
| 单词未找到 | 降一级 (最低Box 1) |

### 8.3 关卡单词选择

优先从低编号盒子选取未掌握的单词。

---

## 9. 文件结构

```
scripts/
├── main_3d.gd          # 主场景控制器
├── grid_manager_3d.gd  # 网格管理
├── input_handler_3d.gd # 输入处理
├── word_cell_3d.gd     # 单元格组件
├── word_manager.gd     # 单词数据管理
├── level_manager.gd    # 关卡流程
├── score_manager.gd    # 分数计算
├── timer_manager.gd    # 计时器
├── hint_manager.gd     # 提示系统
├── story_manager.gd    # 关卡配置
└── ui_manager.gd       # UI管理
```

---

## 10. 配置参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `grid_width` | 18 | 网格宽度 |
| `grid_height` | 4 | 网格高度 |
| `cell_spacing` | 0.35 | 单元格间距 |
| `MAX_HINTS_PER_LEVEL` | 3 | 每关提示次数 |
| `MAX_LEVELS` | 100 | 最大关卡数 |
| `MAX_PLACEMENT_ATTEMPTS` | 100 | 单词放置最大尝试次数 |
| `MAX_RECURSION_DEPTH` | 30 | 路径递归最大深度 |