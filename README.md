# Letter-Blast

A word search puzzle game built with Godot 4.6.

## Description

Letter-Blast is an engaging word search game where players find hidden words in a 4×18 grid. Drag your mouse (or finger on touch devices) through adjacent cells to form words, and validate them against the word library. As you find words, the used cells become grayed out and invisible, gradually revealing the puzzle.

## How to Play

1. **Load the Game**: Launch the game using Godot 4.6
2. **Find Words**: Look for words hidden in the grid
3. **Select Letters**: Click and drag through adjacent cells to form words
   - Cells must be adjacent (including diagonally)
   - No self-intersecting paths allowed
   - Minimum word length: 2 letters
4. **Validate**: Release to submit your word
   - Valid words are marked as found
   - Invalid words are rejected
5. **Complete Level**: Find all words to advance to the next level

## Tech Stack

- **Game Engine**: Godot 4.6
- **Language**: GDScript
- **Platform**: Windows (Desktop)

## Project Structure

```
letter-blast/
├── data/
│   └── words.json          # Word library (21 words)
├── scripts/
│   ├── main.gd            # Main game scene controller
│   ├── grid_manager.gd    # Grid generation and word placement
│   ├── word_manager.gd    # Word validation and tracking
│   ├── input_handler.gd   # Mouse input processing
│   ├── level_manager.gd   # Level management and progression
│   ├── word_cell.gd       # Individual cell component
│   ├── ui_manager.gd      # UI updates and display
│   └── sound_manager.gd   # Sound event signaling
├── scenes/
│   ├── main.tscn          # Main game scene
│   └── word_cell.tscn     # Word cell scene template
├── tests/
│   ├── test_word_manager.gd      # WordManager unit tests
│   ├── test_grid_manager.gd      # GridManager unit tests
│   ├── test_word_placement.gd    # Word placement tests
│   ├── test_ui_manager.gd        # UIManager tests
│   ├── test_level_manager.gd     # LevelManager tests
│   └── test_word_cell.gd         # WordCell unit tests
├── assets/                # Game assets (if any)
├── docs/                  # Documentation
├── project.godot          # Godot project configuration
└── README.md             # This file
```

## Dependencies

- **Godot Engine**: 4.6 (Stable)
  - Download: https://godotengine.org/download/
  - Required modules: GL Compatibility renderer

## Installation

1. Clone or download this repository
2. Install Godot 4.6 from the official website
3. Open the project folder in Godot
4. Press F5 or click "Play" to run

## Features

- ✅ Dynamic grid generation (4×18)
- ✅ Word placement with collision detection
- ✅ Drag-based input with path validation
- ✅ Real-time word validation against library
- ✅ Used cell visualization (grayed out/invisible)
- ✅ Level progression system
- ✅ Word tracking and found word display

## Acceptance Criteria

- [x] Load and parse word library JSON (data/words.json)
- [x] Generate 4×18 grid with word placement
- [x] Support drag with no self-intersecting paths
- [x] Validate words against library
- [x] Used cells grayed out and invisible
- [x] Complete level when all words found

## Tests

Run integration tests using Godot's test framework:

```bash
godot --headless --check-only res://tests/
```

Test files are located in `tests/` directory and cover:

- WordManager: Loading, validation, tracking
- GridManager: Grid generation, word placement, coordinate validation
- UIManager: UI updates, message display
- LevelManager: Level progression, completion checking
- WordCell: Individual cell behavior and state

## Development

### Adding New Words

1. Edit `data/words.json`
2. Add words to the "words" array
3. Restart the game to load new words

### Project Configuration

Edit `project.godot` to configure:
- Project name
- Main scene
- Rendering backend

## License

This project is for educational purposes.
