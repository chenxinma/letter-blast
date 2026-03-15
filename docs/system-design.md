# Letter Blast 系统设计文档

## 概述

Letter Blast 是一款基于 Godot 4.6 的 2D 单词拼写游戏。玩家通过在 15×4 网格中拖拽选择字母来拼写单词，游戏结合了莱特纳盒子（Leitner Box）间隔记忆系统进行词汇学习。

**当前版本**: 2D 实现  
**更新日期**: 2026-03-15  
**状态**: 核心功能已完成并运行稳定

---

## 模块架构

```
Main2D (主控制器)
├── GridManager2D      # 网格管理 (15×4)
├── InputHandler2D     # 输入处理
├── WordManager        # 单词管理
├── LeitnerManager     # 莱特纳盒子学习系统
├── UIManager          # UI显示
├── ScoreManager       # 分数管理
├── TimerManager       # 计时管理
├── HintManager        # 提示管理
└── BGMPlayer          # 背景音乐
```

---

## 1. 网格系统 (GridManager2D)

### 1.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `grid_width` | int | 网格宽度 (默认 15) |
| `grid_height` | int | 网格高度 (默认 4) |
| `cell_spacing` | float | 单元格间距 (默认 75.0) |
| `cells` | Dictionary | 坐标 → 单元格实例映射 |
| `selected_cells` | Array[Node] | 当前选中的单元格 |
| `placed_paths` | Dictionary | 单词 → 放置路径映射 |

### 1.2 单元格坐标系统

- 坐标原点：左上角 (0, 0)
- X 轴：向右递增 (0-14)
- Y 轴：向下递增 (0-3)

```
(0,0) (1,0) (2,0) ... (14,0)
(0,1) (1,1) (2,1) ... (14,1)
(0,2) (1,2) (2,2) ... (14,2)
(0,3) (1,3) (2,3) ... (14,3)
```

### 1.3 单词放置算法

**核心流程：**

```
generate_grid()
    ├── 清空网格和放置记录
    ├── 初始化所有坐标为 null
    ├── 遍历游戏单词 → place_word_in_grid()
    └── 填充空白位置 → 随机字母
```

**单词放置逻辑 (place_word_in_grid)：**

1. 随机选择起始位置
2. 验证首字母是否可放置
3. 递归尝试构建路径 (`try_place_word_recursive`)
4. 路径限制：最大 30 步递归深度
5. 方向限制：8个方向，禁止原路返回

**路径选择规则：**

```
可用方向 = 8方向 - 反向 - 已访问坐标 - 越界坐标
每次尝试时打乱方向顺序 (shuffle)
```

**字母冲突处理：**

- 空位 → 允许放置
- 已占用且字母匹配 → 允许共享
- 已占用且字母不匹配 → 拒绝

### 1.4 2D位置计算

```gdscript
pos_x = (col - grid_width/2.0 + 0.5) * cell_spacing
pos_y = (row - grid_height/2.0 + 0.5) * cell_spacing
```

---

## 2. 输入系统 (InputHandler2D)

### 2.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `selected_path` | Array[Vector2] | 选中的坐标路径 |
| `current_word` | String | 当前拼写的单词 |

### 2.2 事件处理流程

```
鼠标按下 (handle_mouse_press)
    └── 碰撞检测单元格 → select_cell()

鼠标移动 (handle_mouse_motion)
    └── 左键按下时 → 碰撞检测 → select_cell()

鼠标释放 (handle_mouse_release)
    ├── 路径长度 >= 2 → validate_word()
    └── 否则 → clear_selection()
```

### 2.3 碰撞检测

```gdscript
# 使用矩形碰撞检测
for coord in grid_manager.cells:
    var cell = grid_manager.cells[coord]
    if cell and cell is Area2D:
        var shape = cell.get_node("CollisionShape2D")
        var rect = Rect2(global_pos - shape_size/2, shape_size)
        if rect.has_point(mouse_pos):
            return cell
```

### 2.4 选择规则

**邻接判定（8方向）：**

```gdscript
# 允许的相邻关系
dx = abs(current.x - previous.x)
dy = abs(current.y - previous.y)

return (dx <= 1 and dy <= 1) and not (dx == 0 and dy == 0)
```

**选择条件：**

1. 坐标有效
2. 单元格存在且未使用
3. 与上一个选中格相邻（8方向）
4. 未重复选择同一格

### 2.5 单词验证

```
validate_word()
    ├── 长度 >= 2
    ├── leitner_manager.is_game_word() → 是本局单词
    │   ├── grid_manager.mark_used() → 标记已使用
    │   ├── leitner_manager.mark_word_found() → 记录已找到
    │   └── emit_signal("word_validated", word, true)
    └── 不是本局单词 → emit_signal("word_validated", word, false)
```

---

## 3. 莱特纳盒子系统 (LeitnerManager)

### 3.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `boxes` | Dictionary | 5个盒子的单词数据 |
| `current_game_words` | Array | 当前游戏单词列表 |
| `found_words` | Dictionary | 已找到的单词 |
| `total_games_played` | int | 总游戏次数 |
| `total_score` | int | 总分数 |

### 3.2 盒子结构

```gdscript
boxes = {
    "box1": [],  # 1天间隔
    "box2": [],  # 2天间隔
    "box3": [],  # 4天间隔
    "box4": [],  # 7天间隔
    "box5": []   # 14天间隔
}
```

### 3.3 单词晋升/降级

**晋升逻辑：**
```gdscript
func _promote_word(word: String):
    current_box = find_word_box(word)
    if current_box < 5:
        remove_from_box(word, current_box)
        add_to_box(word, current_box + 1)
```

**降级逻辑：**
```gdscript
func _demote_word(word: String):
    current_box = find_word_box(word)
    if current_box > 1:
        remove_from_box(word, current_box)
        add_to_box(word, 1)
```

### 3.4 学习进度保存

**文件路径**: `user://learning_progress.json`

**保存内容**:
- 版本信息
- 最后更新时间
- 单词库数据
- 5个盒子的单词数据
- 统计信息（游戏次数、总分数、掌握单词数）

---

## 4. 分数系统 (ScoreManager)

### 4.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `total_score` | int | 总分数 |
| `level_score` | int | 当前游戏分数 |
| `found_words` | Array | 已找到的单词 |

### 4.2 分数计算规则

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

### 4.3 信号机制

| 信号 | 参数 | 触发时机 |
|------|------|----------|
| `score_changed` | new_score: int | 分数变化时 |
| `level_complete` | score, time_bonus, total | 游戏完成时 |

---

## 5. 计时系统 (TimerManager)

### 5.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `time_remaining` | int | 剩余时间（秒） |
| `time_limit` | int | 时间限制（秒） |
| `is_running` | bool | 是否正在计时 |
| `waiting_to_start` | bool | 等待玩家首次点击 |

### 5.2 计时流程

```
start_timer(180)     # 初始化180秒
    ↓
waiting_to_start = true
    ↓
玩家首次点击 → begin_timer()
    ↓
is_running = true
    ↓
_process(delta)      # 每帧更新倒计时
    ↓
time_remaining <= 0 → emit "time_out"
```

---

## 6. 提示系统 (HintManager)

### 6.1 数据结构

| 属性 | 类型 | 说明 |
|------|------|------|
| `hints_left` | int | 剩余提示次数 |
| `MAX_HINTS_PER_LEVEL` | const | 每局最多3次提示 |
| `remaining_words` | Array | 未找到的单词 |

### 6.2 提示类型

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

---

## 7. UI显示系统 (UIManager)

### 7.1 UI元素

| 元素 | 功能 |
|------|------|
| ScoreLabel | 显示分数 |
| FoundWordsLabel | 已找到的单词列表 |
| WordMeaningsLabel | 本局单词及中文释义 |
| BoxStatsLabel | 莱特纳盒子学习进度 |
| TimerLabel | 倒计时显示 |

### 7.2 显示逻辑

**分数显示：**

```
正常: "Score: {total}"
得分后: "Score: {total} (+{word_score})"  # 显示1.5秒
```

**单词列表显示：**

```
本局单词:
[✓] APPLE - 苹果
[ ] BANANA - 香蕉
```

**学习进度显示：**

```
学习进度: Box1(3) Box2(2) Box3(1) Box4(0) Box5(5)
```

### 7.3 倒计时显示

- 格式: `M:SS` (例如: 2:45)
- 每秒更新

---

## 8. 单元格系统 (WordCell2D)

### 8.1 组件结构

```
WordCell2D (Area2D)
├── BoxSprite (Sprite2D)      # 背景框
├── LetterSprite (Sprite2D)   # 字母显示
└── ClickPlayer (AudioStreamPlayer)  # 点击音效
```

### 8.2 状态

| 状态 | 说明 | 视觉效果 |
|------|------|----------|
| 普通 | 未选中状态 | 彩色背景（3种随机） |
| 选中 | 正在选择中 | 高亮框，字母上移 |
| 已使用 | 单词已找到 | 灰色背景，字母变暗下移 |

### 8.3 颜色系统

- **背景颜色**: 3种随机颜色行 (通过 `_color_row` 控制)
- **选中状态**: 第1列精灵
- **已使用状态**: 第2列精灵

---

## 9. 事件流程图

### 9.1 玩家选择单词流程

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
validate_word() → LeitnerManager验证
    │
    ├── 是本局单词 → mark_used() → 更新分数
    │   │
    │   └── ScoreManager.add_score()
    │       │
    │       └── emit "score_changed"
    │
    └── 不是本局单词 → clear_selection()
```

### 9.2 游戏完成流程

```
LeitnerManager.is_game_complete() == true
    │
    ▼
Main2D._on_game_complete()
    │
    ├── TimerManager.stop_timer()
    ├── ScoreManager.complete_level()
    ├── LeitnerManager.on_game_complete()
    │   ├── 晋升/降级单词
    │   ├── 更新统计
    │   └── save_progress()
    │
    └── await 2秒 → start_new_game()
```

---

## 10. 文件结构

```
scripts/
├── main_2d.gd              # 主场景控制器
├── grid_manager_2d.gd      # 网格管理 (2D)
├── input_handler_2d.gd     # 输入处理 (2D)
├── word_cell_2d.gd         # 单元格组件 (2D)
├── word_manager.gd         # 单词数据管理
├── leitner_manager.gd      # 莱特纳盒子系统
├── score_manager.gd        # 分数计算
├── timer_manager.gd        # 计时器
├── hint_manager.gd         # 提示系统
├── ui_manager.gd           # UI管理
├── start_screen.gd         # 开始界面
└── global_word_manager.gd  # 全局单词管理
```

---

## 11. 配置参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `grid_width` | 15 | 网格宽度 |
| `grid_height` | 4 | 网格高度 |
| `cell_spacing` | 75.0 | 单元格间距（像素） |
| `TIME_LIMIT` | 180 | 游戏时长（秒） |
| `WORDS_PER_GAME` | 4 | 每局单词数 |
| `MAX_HINTS_PER_LEVEL` | 3 | 每局提示次数 |
| `NUM_BOXES` | 5 | 莱特纳盒子数量 |
| `MAX_PLACEMENT_ATTEMPTS` | 100 | 单词放置最大尝试次数 |
| `MAX_RECURSION_DEPTH` | 30 | 路径递归最大深度 |

---

## 12. 数据存储

### 12.1 学习进度文件

**路径**: `user://learning_progress.json`

**结构**:
```json
{
  "version": "1.1",
  "last_updated": "2026-03-15T10:30:00Z",
  "words": [...],
  "total_words_learned": 15,
  "statistics": {
    "total_games_played": 42,
    "total_score": 12580,
    "words_mastered": 8
  },
  "boxes": {
    "box1": [...],
    "box2": [...],
    ...
  }
}
```

### 12.2 单词数据格式

```json
{
  "words": [
    {"en": "APPLE", "zh": "苹果"},
    {"en": "BANANA", "zh": "香蕉"}
  ]
}
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0 | 2026-03-07 | 初始版本，基于3D设计 |
| 2.0 | 2026-03-15 | 更新为2D实现，更新模块架构和配置参数 |

---

**文档结束**
