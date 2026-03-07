# 单词路径放置策略设计文档

> **版本**: 1.0  
> **日期**: 2026-03-07  
> **状态**: 待实现

---

## 一、概述

### 1.1 设计目标

将现有的**直线式单词放置**改为**路径式放置**，每个字母与下一个字母的连接方向可以是上、下、左、右中的任意方向（排除前一个字母的来源方向），实现蛇形路径布局。

### 1.2 核心特性

- **三方向延伸**：每个位置可选择三个可行方向（排除反向）
- **路径不自相交**：路径不能重复经过同一格子
- **无转向约束**：无连续转向次数限制，完全随机选择
- **随机+回溯策略**：递归尝试，失败则回退重选方向
- **仅字母可视化**：玩家看到字母网格，自行探索连接路径

### 1.3 与现有实现的对比

| 维度 | 现有实现 | 新设计 |
|------|---------|--------|
| 放置方式 | 单一方向直线延伸 | 多方向蛇形路径 |
| 方向选择 | 固定一个方向 | 每个字母三选一 |
| 路径形状 | 直线 | S形、L形、Z形等 |
| 难度 | 较低 | 更具挑战性 |
| 代码改动 | - | 修改 `place_word_in_grid` 及相关函数 |

---

## 二、核心算法

### 2.1 放置算法描述

#### 主流程

```
输入：单词 word
输出：是否成功放置 (bool)

算法步骤：
1. 尝试最多 MAX_PLACEMENT_ATTEMPTS 次：
   1.1 随机选择起始坐标 (start_x, start_y)
   1.2 检查起始格子是否可用
   1.3 调用递归函数 try_place_word_recursive 尝试放置
   1.4 如果成功，返回 true
2. 如果所有尝试都失败，返回 false
```

#### 递归放置算法

```
输入：
  - word: 待放置的单词
  - char_index: 当前字符索引（从0开始）
  - path: 已放置的坐标路径
  - visited: 已访问格子的字典（用于快速查找）

输出：是否成功放置剩余字符 (bool)

算法步骤：
1. 如果 char_index == word.length()：
   - 所有字符已放置成功
   - 调用 do_place_word 按路径创建格子
   - 将路径记录到 placed_paths
   - 返回 true

2. 获取当前坐标 current_coord：
   - 如果 char_index == 0，使用起始坐标
   - 否则，使用 path[-1]

3. 获取可用方向列表 available_directions：
   - 调用 get_available_directions(current_coord, prev_direction, visited)
   - 如果列表为空，返回 false（无路可走）

4. 随机打乱方向顺序（增加多样性）

5. 遍历每个方向 direction：
   5.1 计算下一坐标 next_coord = current_coord + direction
   5.2 检查 can_place_char_at(next_coord, word[char_index])
   5.3 如果可以放置：
       - 将 next_coord 加入 path 和 visited
       - 递归调用 try_place_word_recursive(word, char_index + 1, path, visited)
       - 如果递归返回 true，则返回 true
       - 如果递归返回 false，从 path 和 visited 中移除 next_coord（回溯）

6. 所有方向都尝试失败，返回 false
```

### 2.2 辅助算法描述

#### 获取可用方向

```
输入：
  - current_coord: 当前坐标
  - prev_direction: 前一个移动方向（首个字母为 Vector2.ZERO）
  - visited: 已访问格子字典

输出：可用方向数组 Array[Vector2]

算法步骤：
1. 定义反向方向 opposite = prev_direction * -1
2. 遍历 DIRECTIONS 中的每个方向 d：
   2.1 如果 d == opposite，跳过（排除反向）
   2.2 计算 next_coord = current_coord + d
   2.3 如果 next_coord 越界，跳过
   2.4 如果 next_coord 在 visited 中，跳过（避免自相交）
   2.5 将 d 加入结果数组
3. 返回结果数组
```

#### 检查格子是否可放置

```
输入：
  - coord: 目标坐标
  - letter: 待放置的字母

输出：是否可放置 (bool)

算法步骤：
1. 如果 coord 越界，返回 false
2. 获取该格子的 cell = get_cell(coord)
3. 如果 cell == null（格子为空）：
   - 返回 true
4. 如果 cell != null（格子已有字母）：
   - 如果 cell.letter == letter，返回 true（字母匹配，可共享）
   - 否则返回 false（字母冲突）
```

---

## 三、数据结构

### 3.1 新增成员变量

```gdscript
# 记录每个单词的放置路径，用于调试和提示功能
var placed_paths: Dictionary = {}  # word -> Array[Vector2]
```

### 3.2 复用现有定义

```gdscript
# 复用现有的方向枚举和数组
enum Direction {
    DOWN = 0,
    RIGHT,
    UP,
    LEFT
}

const DIRECTIONS: Array[Vector2] = [
    Vector2(0, 1),   # DOWN
    Vector2(1, 0),   # RIGHT
    Vector2(0, -1),  # UP
    Vector2(-1, 0)   # LEFT
]
```

---

## 四、函数签名

### 4.1 主入口函数

```gdscript
func place_word_in_grid(word: String) -> bool:
    # 尝试多次随机起始点放置单词
    # 使用递归回溯算法实现路径式放置
    # 返回：是否成功放置
```

### 4.2 递归放置函数

```gdscript
func try_place_word_recursive(word: String, char_index: int, start_coord: Vector2, prev_direction: Vector2, path: Array[Vector2], visited: Dictionary) -> bool:
    # 递归尝试放置单个字符
    # 参数：
    #   - word: 待放置单词
    #   - char_index: 当前字符索引
    #   - start_coord: 起始坐标（仅首个字符使用）
    #   - prev_direction: 前一个移动方向
    #   - path: 已放置的坐标路径
    #   - visited: 已访问格子的字典 {coord: true}
    # 返回：是否成功放置剩余字符
```

### 4.3 辅助函数

```gdscript
func get_available_directions(current_coord: Vector2, prev_direction: Vector2, visited: Dictionary) -> Array[Vector2]:
    # 获取当前位置可用的方向列表
    # 排除：反向、越界、已访问
    # 返回：可用方向数组

func can_place_char_at(coord: Vector2, letter: String) -> bool:
    # 检查指定格子是否可放置指定字母
    # 允许：空格子、字母匹配的格子
    # 返回：是否可放置

func do_place_word_by_path(word: String, path: Array[Vector2]) -> void:
    # 按照路径创建格子并放置单词
    # 替代原有的 do_place_word 函数
```

---

## 五、放置流程图

```
place_word_in_grid(word)
        │
        ▼
    ┌──────────────────┐
    │ 尝试次数 < 100？  │
    └────────┬─────────┘
             │
        ┌────┴────┐
        │ 是      │ 否
        ▼         ▼
  ┌──────────┐  返回 false
  │ 随机起点  │
  └────┬─────┘
       │
       ▼
  ┌────────────────────────┐
  │ try_place_word_recursive│
  │ (word, 0, start, ...)   │
  └────────┬───────────────┘
           │
      ┌────┴────┐
      │ 成功？   │
      └────┬────┘
           │
      ┌────┴────┐
      │ 是       │ 否
      ▼          ▼
  记录路径    继续尝试
  返回 true
```

### 递归流程图

```
try_place_word_recursive(word, char_index, ...)
        │
        ▼
  ┌─────────────────┐
  │ char_index ==   │
  │ word.length()?  │
  └────────┬────────┘
           │
      ┌────┴────┐
      │ 是       │ 否
      ▼          ▼
  放置成功    ┌───────────────────┐
  返回 true   │ get_available_    │
              │ directions()      │
              └────────┬──────────┘
                       │
                       ▼
              ┌────────────────┐
              │ 方向列表为空？  │
              └────────┬───────┘
                       │
                  ┌────┴────┐
                  │ 是       │ 否
                  ▼          ▼
              返回 false   遍历方向
                           │
                           ▼
                      ┌─────────────┐
                      │ 尝试该方向   │
                      │ 递归调用     │
                      └──────┬──────┘
                             │
                        ┌────┴────┐
                        │ 成功？    │
                        └────┬────┘
                             │
                        ┌────┴────┐
                        │ 是       │ 否
                        ▼          ▼
                    返回 true   回溯，继续下一方向
```

---

## 六、示例场景

### 6.1 简单示例：放置 "CAT"

```
初始网格（4×18，简化为4×5展示）：
┌───┬───┬───┬───┬───┐
│   │   │   │   │   │
├───┼───┼───┼───┼───┤
│   │   │   │   │   │
├───┼───┼───┼───┼───┤
│   │   │   │   │   │
├───┼───┼───┼───┼───┤
│   │   │   │   │   │
└───┴───┴───┴───┴───┘

步骤1：随机选择起点 (2, 1)，放置 'C'
方向选择：DOWN, RIGHT, UP, LEFT（无前向，四个都可用）
随机选择：DOWN

步骤2：当前位置 (2, 2)，放置 'A'
前向：DOWN，排除反向 UP
可选方向：DOWN, RIGHT, LEFT
随机选择：RIGHT

步骤3：当前位置 (3, 2)，放置 'T'
前向：RIGHT，排除反向 LEFT
可选方向：DOWN, RIGHT, UP
随机选择：RIGHT

结果：
┌───┬───┬───┬───┬───┐
│   │   │   │   │   │
├───┼───┼───┼───┼───┤
│   │   │ C │   │   │
├───┼───┼───┼───┼───┤
│   │   │ A │ T │   │
├───┼───┼───┼───┼───┤
│   │   │   │   │   │
└───┴───┴───┴───┴───┘

路径：[(2,1), (2,2), (3,2)]
字母：C -> A -> T
```

### 6.2 复杂示例：放置 "BANANA"（含转向）

```
假设网格中已有部分字母：

┌───┬───┬───┬───┬───┬───┐
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │ A │ N │ A │ N │   │  <- 已有 "ANAN"
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
└───┴───┴───┴───┴───┴───┘

尝试放置 "BANANA"：
起点 (0, 1)，放置 'B'
方向选择：DOWN, RIGHT（LEFT越界，UP越界）
选择：DOWN -> 放置 'A' 在 (1, 1) ✓（字母匹配）

当前位置 (1, 1)，已放置 "BA"
前向：DOWN，排除反向 UP
可选方向：DOWN, RIGHT, LEFT
选择：RIGHT -> 放置 'N' 在 (1, 2) ✓（字母匹配）

当前位置 (1, 2)，已放置 "BAN"
前向：RIGHT，排除反向 LEFT
可选方向：DOWN, RIGHT, UP
选择：RIGHT -> 放置 'A' 在 (1, 3) ✓（字母匹配）

当前位置 (1, 3)，已放置 "BANA"
前向：RIGHT，排除反向 LEFT
可选方向：DOWN, RIGHT, UP
选择：RIGHT -> 放置 'N' 在 (1, 4) ✓（字母匹配）

当前位置 (1, 4)，已放置 "BANAN"
前向：RIGHT，排除反向 LEFT
可选方向：DOWN, UP, RIGHT
选择：DOWN -> 放置 'A' 在 (2, 4) ✓（新格子）

结果：
┌───┬───┬───┬───┬───┬───┐
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│ B │ A │ N │ A │ N │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │ A │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
└───┴───┴───┴───┴───┴───┘

路径：[(0,1), (1,1), (1,2), (1,3), (1,4), (2,4)]
字母：B -> A -> N -> A -> N -> A
```

### 6.3 回溯示例：放置 "DOG"

```
初始网格：
┌───┬───┬───┬───┐
│   │   │ X │   │
├───┼───┼───┼───┤
│   │ X │   │   │
├───┼───┼───┼───┤
│   │   │   │   │
├───┼───┼───┼───┤
│   │   │   │   │
└───┴───┴───┴───┘
（X 表示已有字母）

尝试放置 "DOG"：
起点 (1, 1)，放置 'D' ✓
方向：DOWN（RIGHT冲突X，UP越界，LEFT越界）
选择：DOWN -> (1, 2) 放置 'O' ✓

当前位置 (1, 2)，已放置 "DO"
前向：DOWN，排除反向 UP
可选方向：DOWN, RIGHT, LEFT
尝试 DOWN -> (1, 3)，但格子已有字母且不匹配 -> 失败
尝试 RIGHT -> (2, 2)，放置 'G' ✓

成功！路径：[(1,1), (1,2), (2,2)]
```

---

## 七、边界情况处理

### 7.1 空网格首个单词

- 直接随机选择起点和方向
- 无需考虑字母冲突
- 成功率：100%

### 7.2 网格即将填满

- 可用空间减少，可能需要多次尝试
- 失败时：跳过该单词或扩容网格
- 建议：保持至少 30% 空白格子

### 7.3 单词长度超过网格维度

- 最大单词长度：min(GRID_WIDTH, GRID_HEIGHT) = 4（当前配置）
- 需要：修改为允许蛇形路径，最大长度可达 GRID_WIDTH × GRID_HEIGHT
- 建议：限制最大单词长度为 8 字母（根据游戏策划）

### 7.4 所有起始点都失败

- 返回 false
- 调用方可以选择：
  - 跳过该单词
  - 重新生成网格
  - 扩大网格尺寸

---

## 八、性能考虑

### 8.1 时间复杂度

- 单次放置尝试：O(L × D)，L = 单词长度，D = 方向数（最多3）
- 最大尝试次数：MAX_PLACEMENT_ATTEMPTS = 100
- 最坏情况：O(100 × L × 3) = O(L)

### 8.2 空间复杂度

- 路径存储：O(L)
- 访问记录：O(L)
- placed_paths 字典：O(N × L)，N = 单词数量

### 8.3 优化建议

- 对于长单词（> 6 字母），增加尝试次数到 200
- 对于短单词（≤ 3 字母），减少尝试次数到 50
- 可选：预计算可行起点位置池，减少随机尝试

---

## 九、测试用例

### 9.1 单元测试

```gdscript
# test_path_placement.gd

func test_simple_path_placement():
    # 测试简单单词路径放置
    var word = "CAT"
    var result = grid_manager.place_word_in_grid(word)
    assert(result == true)
    assert(grid_manager.placed_paths.has(word))
    assert(grid_manager.placed_paths[word].size() == 3)

func test_no_self_intersect():
    # 测试路径不自相交
    var word = "HELLO"
    grid_manager.place_word_in_grid(word)
    var path = grid_manager.placed_paths[word]
    var visited = {}
    for coord in path:
        assert(not visited.has(coord))
        visited[coord] = true

func test_letter_sharing():
    # 测试字母共享
    grid_manager.place_word_in_grid("CAT")
    grid_manager.place_word_in_grid("BAT")
    # 两个单词可以共享 'A' 和 'T'
    var cat_path = grid_manager.placed_paths["CAT"]
    var bat_path = grid_manager.placed_paths["BAT"]
    # 验证是否有共享格子

func test_backtracking():
    # 测试回溯机制
    # 创建一个几乎填满的网格
    # 测试是否能找到可行路径
    pass

func test_max_attempts():
    # 测试达到最大尝试次数
    # 创建一个无法放置的网格
    # 验证返回 false
    pass
```

### 9.2 集成测试

```gdscript
func test_multiple_words_placement():
    # 测试多个单词连续放置
    var words = ["APPLE", "BANANA", "CHERRY"]
    for word in words:
        var result = grid_manager.place_word_in_grid(word)
        assert(result == true)

func test_full_game_flow():
    # 测试完整游戏流程
    grid_manager.generate_grid()
    # 验证所有目标单词都被放置
    # 验证没有格子被重复占用（除非字母匹配）
    pass
```

---

## 十、实现计划

### 10.1 修改文件

| 文件 | 修改内容 |
|------|---------|
| `scripts/grid_manager.gd` | 修改 `place_word_in_grid`，新增递归函数和辅助函数 |

### 10.2 实现步骤

1. **添加成员变量**
   - `placed_paths: Dictionary`

2. **实现辅助函数**
   - `get_available_directions()`
   - `can_place_char_at()`

3. **实现递归放置函数**
   - `try_place_word_recursive()`

4. **修改主函数**
   - 重构 `place_word_in_grid()`
   - 新增 `do_place_word_by_path()`

5. **编写测试**
   - 单元测试
   - 集成测试

6. **性能优化**
   - 调整尝试次数
   - 添加早期失败检测

---

## 十一、风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| 长单词放置失败率高 | 游戏体验差 | 增加尝试次数，优化起点选择 |
| 网格空间不足 | 无法放置所有单词 | 动态调整网格大小 |
| 性能问题（大量单词） | 加载时间长 | 异步生成，预计算可行位置 |
| 路径过于复杂 | 玩家难以发现 | 可选：添加路径提示功能 |

---

## 十二、版本历史

| 版本 | 日期 | 说明 | 作者 |
|------|------|------|------|
| 1.0 | 2026-03-07 | 初始设计文档 | Claude |

---

**文档结束**