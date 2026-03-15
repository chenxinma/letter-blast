# Letter-Blast

A word search puzzle game built with Godot 4.6.

## Description

Letter-Blast is an engaging word search game where players find hidden words in a 15×4 grid. Drag your mouse through adjacent cells to form words, and validate them against the word library. The game features the Leitner Box spaced repetition system to help players learn and remember words effectively.

## How to Play

1. **Load the Game**: Launch the game using Godot 4.6
2. **Find Words**: Look for words hidden in the grid (15 columns × 4 rows)
3. **Select Letters**: Click and drag through adjacent cells to form words
   - Cells must be adjacent (including diagonally)
   - No self-intersecting paths allowed
   - Minimum word length: 2 letters
4. **Validate**: Release to submit your word
   - Valid words are marked as found
   - Invalid words are rejected
5. **Complete Game**: Find all 4 words to complete the game and advance

## Tech Stack

- **Game Engine**: Godot 4.6
- **Language**: GDScript
- **Platform**: Windows (Desktop)
- **Renderer**: OpenGL 3.3 Compatibility Mode

## Project Structure

```
letter-blast/
├── data/
│   ├── words.json               # Word library (19 words with Chinese translations)
│   └── vocabulary-xixi.json     # Extended vocabulary (optional)
├── scripts/
│   ├── main_2d.gd              # Main game scene controller
│   ├── grid_manager_2d.gd      # Grid generation and word placement (15×4)
│   ├── word_manager.gd         # Word validation and tracking
│   ├── input_handler_2d.gd     # Mouse input processing
│   ├── leitner_manager.gd      # Leitner Box spaced repetition system
│   ├── score_manager.gd        # Score calculation and management
│   ├── timer_manager.gd        # Game timer (180 seconds)
│   ├── hint_manager.gd         # Hint system (3 hints per game)
│   ├── ui_manager.gd           # UI updates and display
│   ├── word_cell_2d.gd         # Individual cell component
│   ├── start_screen.gd         # Start screen controller
│   └── global_word_manager.gd  # Global word management
├── scenes/
│   ├── main_2d.tscn            # Main game scene (2D)
│   ├── word_cell_2d.tscn       # Word cell scene template
│   ├── start_screen.tscn       # Start menu scene
│   └── loading.tscn            # Loading screen
├── tests/
│   ├── test_word_manager.gd    # WordManager unit tests
│   └── test_ui_manager.gd      # UIManager tests
├── docs/                        # Documentation
│   ├── 游戏策划方案.md          # Game design document (Chinese)
│   ├── system-design.md        # System architecture document
│   ├── 美术风格.md              # Art style guidelines
│   ├── 视觉资产清单.md          # Visual assets inventory
│   ├── performance_results.md  # Performance test results
│   ├── plans/                  # Implementation plans
│   └── assets_define/          # Asset definitions
├── resources/                   # Godot resource files
├── project.godot               # Godot project configuration
└── README.md                   # This file
```

## Dependencies

- **Godot Engine**: 4.6 (Stable)
  - Download: https://godotengine.org/download/
  - Required renderer: OpenGL 3.3 Compatibility Mode

## Installation

1. Clone or download this repository
2. Install Godot 4.6 from the official website
3. Open the project folder in Godot
4. Press F5 or click "Play" to run

## Features

### Core Features (Implemented)
- ✅ Dynamic grid generation (15×4)
- ✅ Word placement algorithm with collision detection
- ✅ Drag-based input with path validation
- ✅ Real-time word validation against library
- ✅ Used cell visualization
- ✅ Leitner Box spaced repetition system
- ✅ Score calculation with time bonuses
- ✅ Game timer (180 seconds)
- ✅ Hint system (3 hints per game)
- ✅ Word meanings display (English + Chinese)
- ✅ Learning progress tracking
- ✅ Start screen with word import
- ✅ Background music support

### Word Library
Currently contains 19 fruit-related words:
```
APPLE, BANANA, CHERRY, DATE, ELDERBERRY, FIG, GRAPES, HONEYDEW, 
KIWI, LEMON, MANGO, NECTARINE, PAPAYA, QUINCE, RAISIN, 
STRAWBERRY, TANGERINE, ULUBAR, VANILLA
```

## Game Mechanics

### Leitner Box System
The game implements the Leitner Box method for spaced repetition:

| Box | Review Interval | Description |
|-----|-----------------|-------------|
| Box 1 | 1 day | New words, review next day |
| Box 2 | 2 days | Review after 2 days |
| Box 3 | 4 days | Review after 4 days |
| Box 4 | 7 days | Review after 7 days |
| Box 5 | 14 days | Mastered words |

**Promotion/Demotion Rules:**
- Word found successfully: Promote to next box
- Word not found: Demote to Box 1

### Scoring System

**Base Score by Word Length:**

| Word Length | Base Score | Multiplier | Final Score |
|-------------|------------|------------|-------------|
| 2-3 letters | 10 | ×1.0 | 10 |
| 4-5 letters | 20 | ×1.5 | 30 |
| 6-7 letters | 40 | ×2.0 | 80 |
| 8+ letters | 80 | ×3.0 | 240 |

**Time Bonus:** 0.5 points per remaining second
**Perfect Bonus:** +100 points if >50% time remains

## Configuration

### Game Settings
Edit the following in script files:
- `TIME_LIMIT` in `main_2d.gd`: Game duration in seconds (default: 180)
- `WORDS_PER_GAME` in `leitner_manager.gd`: Words per game (default: 4)
- `MAX_HINTS_PER_LEVEL` in `hint_manager.gd`: Hints per game (default: 3)
- Grid size in `grid_manager_2d.gd`: Default 15×4

### Project Configuration
Edit `project.godot` to configure:
- Project name
- Main scene
- Rendering backend
- Window settings

## Development

### Adding New Words

1. Edit `data/words.json`:
```json
{
  "words": [
    {"en": "NEWWORD", "zh": "中文释义"},
    ...
  ]
}
```

2. Or use the start screen to import a custom word list file

3. Restart the game to load new words

### Word Import Format
```json
{
  "words": [
    {"en": "WORD1", "zh": "Meaning 1"},
    {"en": "WORD2", "zh": "Meaning 2"}
  ]
}
```

## Testing

Run tests using Godot's test framework:

```bash
godot --headless --check-only res://tests/
```

Test files are located in `tests/` directory and cover:

- `test_word_manager.gd`: Word loading, validation, tracking
- `test_ui_manager.gd`: UI updates, display functionality

## Save Data

Learning progress is automatically saved to:
- `user://learning_progress.json` - Leitner box data and statistics
- `user://word_progress.json` - Word learning progress

## Documentation

- [游戏策划方案.md](docs/游戏策划方案.md) - Complete game design document (Chinese)
- [system-design.md](docs/system-design.md) - System architecture and technical details
- [美术风格.md](docs/美术风格.md) - Art style guidelines (Chinese)
- [视觉资产清单.md](docs/视觉资产清单.md) - Visual assets inventory (Chinese)
- [performance_results.md](docs/performance_results.md) - Performance test results

## License

This project is for educational purposes.
