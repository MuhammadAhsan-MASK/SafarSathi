import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherWarning {
  final String message;
  final double latitude;
  final double longitude;

  WeatherWarning(this.message, this.latitude, this.longitude);
}

class DestinationWeather {
  final String destination;
  final double temperature;
  final String condition;
  final String icon;
  final double windSpeed;
  final String advice;
  final bool isSevere;
  final String? warningMessage;

  const DestinationWeather({
    required this.destination,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.windSpeed,
    required this.advice,
    this.isSevere = false,
    this.warningMessage,
  });
}

class WeatherService {
  /// Checks the weather for a given destination and returns a [WeatherWarning]
  /// if conditions are severe (e.g. storms, heavy rain/snow), otherwise null.
  static Future<WeatherWarning?> checkWeatherWarning(String destination) async {
    try {
      // 1. Geocode the destination
      final geoUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(destination)}&count=1&format=json');
      final geoResponse = await http.get(geoUrl).timeout(const Duration(seconds: 4));

      if (geoResponse.statusCode != 200) return null;

      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || (geoData['results'] as List).isEmpty) {
        return null;
      }

      final lat = (geoData['results'][0]['latitude'] as num).toDouble();
      final lon = (geoData['results'][0]['longitude'] as num).toDouble();

      // 2. Fetch current weather
      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final weatherResponse = await http.get(weatherUrl).timeout(const Duration(seconds: 4));

      if (weatherResponse.statusCode != 200) return null;

      final weatherData = jsonDecode(weatherResponse.body);
      final current = weatherData['current_weather'];
      final weatherCode = current['weathercode'] as int;
      final temp = (current['temperature'] as num).toDouble();
      final windSpeed = (current['windspeed'] as num).toDouble();

      String? warningMsg;

      if ([63, 65, 81, 82].contains(weatherCode)) {
        warningMsg = 'Natural Disaster Alert: Heavy rain detected in $destination. High risk of flooding or landslides. Weather is not suitable for travelling.';
      } else if ([73, 75, 86].contains(weatherCode)) {
        warningMsg = 'Disaster Alert: Heavy snow/blizzard detected in $destination. Strong risk of roadblocks. Weather is not suitable for travelling.';
      } else if ([95, 96, 99].contains(weatherCode)) {
        warningMsg = 'Disaster Alert: Severe thunderstorms detected in $destination. Traveling is highly dangerous and not recommended.';
      } else if (windSpeed > 75.0) {
        warningMsg = 'Natural Disaster Alert: Cyclone/Hurricane force winds ($windSpeed km/h) detected in $destination. Weather is not suitable for travelling.';
      } else if (temp > 45.0) {
        warningMsg = 'Disaster Alert: Extreme heatwave ($temp°C) in $destination. Weather is not suitable for travelling.';
      } else if (temp < -15.0) {
        warningMsg = 'Disaster Alert: Extreme freezing conditions ($temp°C) in $destination. Weather is not suitable for travelling.';
      }

      if (warningMsg != null) {
        return WeatherWarning(warningMsg, lat, lon);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches rich structured weather details and clothing/travel advisory for a destination.
  static Future<DestinationWeather?> getDestinationWeatherDetails(String destination) async {
    try {
      final geoUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(destination)}&count=1&format=json');
      final geoResponse = await http.get(geoUrl).timeout(const Duration(seconds: 4));
      if (geoResponse.statusCode != 200) return null;

      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || (geoData['results'] as List).isEmpty) {
        return null;
      }

      final lat = (geoData['results'][0]['latitude'] as num).toDouble();
      final lon = (geoData['results'][0]['longitude'] as num).toDouble();

      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final weatherResponse = await http.get(weatherUrl).timeout(const Duration(seconds: 4));
      if (weatherResponse.statusCode != 200) return null;

      final weatherData = jsonDecode(weatherResponse.body);
      final current = weatherData['current_weather'];
      final temp = (current['temperature'] as num).toDouble();
      final wind = (current['windspeed'] as num).toDouble();
      final code = current['weathercode'] as int;

      String condition = 'Sunny / Clear';
      String icon = '☀️';

      if ([1, 2, 3].contains(code)) {
        condition = 'Partly Cloudy';
        icon = '⛅';
      } else if ([45, 48].contains(code)) {
        condition = 'Foggy / Overcast';
        icon = '🌫️';
      } else if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) {
        condition = 'Rainy';
        icon = '🌧️';
      } else if ([71, 73, 75, 77, 85, 86].contains(code)) {
        condition = 'Snowy';
        icon = '❄️';
      } else if ([95, 96, 99].contains(code)) {
        condition = 'Thunderstorms';
        icon = '⛈️';
      }

      // Advisory calculation (aligned with checkWeatherWarning thresholds)
      String advice;
      bool isSevere = false;

      if ([95, 96, 99].contains(code)) {
        advice = 'Thunderstorms detected! Avoid open mountain passes and stay indoors.';
        isSevere = true;
      } else if (wind > 75.0) {
        advice = 'Cyclone-force winds ($wind km/h)! Travel is unsafe right now.';
        isSevere = true;
      } else if (temp > 45.0) {
        advice = 'Extreme heatwave ($temp°C)! Avoid daytime travel and stay hydrated.';
        isSevere = true;
      } else if (temp < -15.0) {
        advice = 'Extreme freeze ($temp°C)! High risk of icy roads and frostbite.';
        isSevere = true;
      } else if ([73, 75, 86].contains(code)) {
        advice = 'Heavy snowfall detected! High risk of roadblocks. Pack heavy thermals and snow grip boots.';
        isSevere = true;
      } else if ([71, 77, 85].contains(code)) {
        advice = 'Light snowfall expected ($temp°C). Pack warm thermal layers and waterproof boots.';
      } else if ([63, 65, 81, 82].contains(code)) {
        advice = 'Heavy rain alert! Watch for slippery roads or landslides and carry waterproof gear.';
        isSevere = true;
      } else if ([51, 53, 55, 61, 80].contains(code)) {
        advice = 'Light to moderate rain! Carry waterproof raincoats, umbrellas, and shoe covers.';
      } else if (temp <= 5.0) {
        advice = 'Freezing mountain cold ($temp°C). Wear thermal base layers, down jackets, and beanies.';
      } else if (temp <= 15.0) {
        advice = 'Chilly weather ($temp°C). Carry a fleece jacket or sweater for comfortable sightseeing.';
      } else if (temp >= 35.0) {
        advice = 'High heat ($temp°C). Stay hydrated, wear light cotton clothing, and carry sunglasses.';
      } else {
        advice = 'Pleasant travel weather ($temp°C). Ideal for outdoor excursions and walking!';
      }

      return DestinationWeather(
        destination: destination,
        temperature: temp,
        condition: condition,
        icon: icon,
        windSpeed: wind,
        advice: advice,
        isSevere: isSevere,
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetches a simple string representation of the current weather for a destination.
  static Future<String> getCurrentWeatherCondition(String destination) async {
    try {
      final details = await getDestinationWeatherDetails(destination);
      if (details != null) {
        return '${details.condition}, ${details.temperature.toStringAsFixed(1)}°C';
      }
      return 'Unknown Weather';
    } catch (_) {
      return 'Unknown Weather';
    }
  }
}
