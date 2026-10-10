import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherWarning {
  final String message;
  final double latitude;
  final double longitude;

  WeatherWarning(this.message, this.latitude, this.longitude);
}

class WeatherService {
  /// Checks the weather for a given destination and returns a [WeatherWarning]
  /// if conditions are severe (e.g. storms, heavy rain/snow), otherwise null.
  static Future<WeatherWarning?> checkWeatherWarning(String destination) async {
    try {
      // 1. Geocode the destination
      final geoUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(destination)}&count=1&format=json');
      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode != 200) return null;

      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || (geoData['results'] as List).isEmpty) {
        return null; // Could not find destination
      }

      final lat = geoData['results'][0]['latitude'] as double;
      final lon = geoData['results'][0]['longitude'] as double;

      // 2. Fetch current weather
      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode != 200) return null;

      final weatherData = jsonDecode(weatherResponse.body);
      final current = weatherData['current_weather'];
      final weatherCode = current['weathercode'] as int;
      final temp = (current['temperature'] as num).toDouble();
      final windSpeed = (current['windspeed'] as num).toDouble();

      // WMO Weather interpretation codes (WMO code)
      // Reference: https://open-meteo.com/en/docs
      // Severe weather codes:
      // 63, 65 (Heavy Rain)
      // 73, 75 (Heavy Snow)
      // 81, 82 (Violent Rain showers)
      // 86 (Heavy snow showers)
      // 95, 96, 99 (Thunderstorm with/without hail)
      
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

      // FOR DEMO PURPOSES (To test if the city name triggers a mock warning if weather is fine)
      if (warningMsg == null) {
        if (destination.toLowerCase().contains("kashmir")) {
          warningMsg = 'Natural Disaster Alert: Landslide reported in some parts of Kashmir right now. Not suitable for travelling.';
        } else if (destination.toLowerCase().contains("karachi")) {
          warningMsg = 'Disaster Alert: Extreme Heatwave temperatures are uncomfortably high in Karachi right now. Not suitable for travelling.';
        } else if (destination.toLowerCase().contains("quetta") || destination.toLowerCase().contains("islamabad")) {
           warningMsg = 'Natural Disaster Alert: A moderate earthquake was recently detected near $destination. Travel is currently not suitable due to aftershock risks.';
        }
      }

      if (warningMsg != null) {
        return WeatherWarning(warningMsg, lat, lon);
      }

      return null;
    } catch (e) {
      // In case of any API error, proceed without blocking the user
      return null;
    }
  }

  /// Fetches a simple string representation of the current weather for a destination.
  static Future<String> getCurrentWeatherCondition(String destination) async {
    try {
      final geoUrl = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(destination)}&count=1&format=json');
      final geoResponse = await http.get(geoUrl);
      if (geoResponse.statusCode != 200) return 'Unknown Weather';
      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || (geoData['results'] as List).isEmpty) return 'Unknown Weather';
      
      final lat = geoData['results'][0]['latitude'] as double;
      final lon = geoData['results'][0]['longitude'] as double;
      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final weatherResponse = await http.get(weatherUrl);
      if (weatherResponse.statusCode != 200) return 'Unknown Weather';
      
      final weatherData = jsonDecode(weatherResponse.body);
      final current = weatherData['current_weather'];
      final temp = current['temperature'];
      final code = current['weathercode'] as int;
      
      String condition = 'Sunny/Clear';
      if ([1, 2, 3].contains(code)) condition = 'Partly Cloudy';
      else if ([45, 48].contains(code)) condition = 'Foggy/Overcast';
      else if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) condition = 'Rainy';
      else if ([71, 73, 75, 77, 85, 86].contains(code)) condition = 'Snowy';
      else if ([95, 96, 99].contains(code)) condition = 'Thunderstorms';
      
      return '$condition, $temp°C';
    } catch (_) {
      return 'Unknown Weather';
    }
  }
}
