# Weather App

A Flutter weather app with current conditions, a 7-day forecast, city search with autocomplete, and weather for your current location.

## Features

- Current weather for any city
- 7-day forecast screen
- City search with autocomplete (`flutter_typeahead`)
- Weather for your current location with `geolocator`
- Data from the [WeatherAPI.com](https://www.weatherapi.com/) REST API over HTTPS

## Tech stack

- Flutter / Dart
- http, geolocator, flutter_typeahead, google_fonts
- WeatherAPI.com

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
git clone https://github.com/diegoabreug/weather-app.git
cd weather-app
flutter pub get
flutter run --dart-define=WEATHER_API_KEY=your_api_key
```

> Get a free API key at [weatherapi.com](https://www.weatherapi.com/). The key is passed at build time and is never stored in the code.

## Project structure

```
lib/
├── main.dart
├── services/weather_services.dart   # WeatherAPI client
└── screen/                          # Home and forecast screens
```

## Author

**Diego Abreu** · [GitHub](https://github.com/diegoabreug)
