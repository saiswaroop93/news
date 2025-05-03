import 'dart:convert'; // For jsonDecode
import 'dart:async'; // For Future

import '../core/network/network_manager.dart'; // Import NetworkManager

/// A service class to interact with the Open-Meteo weather API.
class WeatherApiService {
  final NetworkManager _networkManager;

  /// Creates a [WeatherApiService].
  ///
  /// Requires a [NetworkManager] instance to handle HTTP requests.
  WeatherApiService(this._networkManager);

  /// Fetches weather data for the given [latitude] and [longitude].
  ///
  /// Returns a `Map<String, dynamic>` containing the weather data.
  /// Throws an [Exception] if fetching or parsing fails.
  Future<Map<String, dynamic>> fetchWeather(double latitude, double longitude) async {
    // Construct the API URL
    // Example URL: https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,wind_speed_10m',
      'hourly': 'temperature_2m,relative_humidity_2m,wind_speed_10m',
    };
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', queryParameters);

    try {
      // Make the network request using NetworkManager
      final responseBody = await _networkManager.getData(url);

      // Decode the JSON response
      final decodedJson = jsonDecode(responseBody) as Map<String, dynamic>;
      return decodedJson;

    } catch (e) {
      // Handle errors from NetworkManager or jsonDecode
      // Rethrow a more specific exception or log the original error
      print('Error fetching or parsing weather data: $e'); // Optional: Log the error
      throw Exception('Failed to fetch or parse weather data: $e');
    }
  }
}
