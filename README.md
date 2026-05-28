# ✨ SoulJournal

A minimal, aesthetic personal journaling app built with Flutter. SoulJournal offers a calming, scrapbook-style interface where your thoughts live on soft pastel cards with a textured grain background.

## Features

- **Scrapbook Grid Layout** — Entries are displayed as pastel-colored cards in a responsive 2-column grid.
- **Dynamic Color Shifting** — Card background color changes in real-time as you type, cycling through a curated pastel palette (Mint, Pink, Lavender, Peach, Ice Blue, Soft Purple).
- **Create & Edit Entries** — Tap the `+` FAB to write a new entry, or tap the edit icon on any card to update it.
- **Long-Press to Delete** — Long-press a card to reveal the delete option with haptic feedback, keeping the UI clean.
- **Undo Deletion** — Accidentally deleted an entry? An undo snackbar appears immediately to restore it.
- **Local Persistence** — All entries are saved locally using `SharedPreferences` and restored on app launch.
- **Grain Texture Background** — A subtle hand-painted grain effect adds warmth and texture to the canvas.
- **Gradient Header** — The app title uses a mauve → rose → amber gradient rendered with `ShaderMask`.

## Screenshots

_Coming soon_

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.3) |
| State Management | `setState` |
| Persistence | `shared_preferences` ^2.5.5 |
| Typography | `google_fonts` ^8.0.2 (Inter + Playfair Display) |
| Unique IDs | `uuid` ^4.5.3 |
| Design System | Material 3 |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- An emulator/simulator or a physical device connected

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd soul_journal

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
soul_journal/
├── lib/
│   └── main.dart          # App entry point, all widgets & logic
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── web/                   # Web platform files
├── windows/               # Windows platform files
├── linux/                 # Linux platform files
├── macos/                 # macOS platform files
├── pubspec.yaml           # Dependencies & project config
└── README.md
```

## Architecture Overview

The app is structured as a single-file Flutter application (`main.dart`) containing:

| Component | Role |
|---|---|
| `JournalEntry` | Data model with JSON serialization for persistence |
| `SoulJournalApp` | Root `MaterialApp` with Material 3 theme and Google Fonts |
| `ScrapbookHome` | Main screen — manages entry state, CRUD operations, and grid layout |
| `ScrapbookCard` | Individual journal card with edit, delete, date/time display |
| `EntryDialog` | Modal dialog for creating/editing entries with live color shifts |
| `GrainBackground` | Custom painter that renders a subtle film-grain texture |

## License

This project is for personal use.
