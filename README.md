# Nutrigram

A modern nutrition tracking app built with Flutter that helps users monitor their daily food intake and nutritional goals.

## Features

- Quick meal capture with camera
- Daily calorie and macronutrient tracking
- Recent meals history
- Macro breakdown visualization
- Clean and modern UI

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code with Flutter extensions
- Gemini API key from Google AI Studio

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/nutrigram.git
```

2. Navigate to the project directory:
```bash
cd nutrigram
```

3. Set up API configuration:
   - Copy `lib/config/api_config.template.dart` to `lib/config/api_config.dart`
   - Replace `YOUR_API_KEY_HERE` with your actual Gemini API key
   - Note: `api_config.dart` is gitignored and won't be committed to the repository

4. Install dependencies:
```bash
flutter pub get
```

5. Run the app:
```bash
flutter run
```

Alternatively, you can provide the API key during runtime:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

## Project Structure

```
lib/
  ├── components/         # Reusable UI components
  │   ├── custom_app_bar.dart
  │   ├── custom_bottom_nav.dart
  │   ├── meal_card.dart
  │   └── macro_item.dart
  └── main.dart          # Main application file
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
