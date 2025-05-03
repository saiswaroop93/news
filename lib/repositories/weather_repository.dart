import 'dart:async'; // For Future

import '../models/weather_model.dart'; // Import the Weather model
import '../services/weather_api_service.dart'; // Import the WeatherApiService

/// A repository responsible for fetching and parsing weather data.
///
/// It interacts with the [WeatherApiService] to get raw data and then
/// uses the [Weather] model to parse it into a structured object.
class WeatherRepository {
  final WeatherApiService _weatherApiService;

  /// Creates a [WeatherRepository].
  ///
  /// Requires a [WeatherApiService] instance.
  WeatherRepository(this._weatherApiService);

  /// Fetches weather data for given coordinates and parses it into a [Weather] object.
  ///
  /// Throws an [Exception] if fetching or parsing fails.
  Future<Weather> fetchWeather(double latitude, double longitude) async {
    try {
      // Fetch raw weather data (Map) from the API service
      final Map<String, dynamic> weatherData =
          await _weatherApiService.fetchWeather(latitude, longitude);

      // Parse the raw data into a Weather object using the factory constructor
      final Weather weather = Weather.fromJson(weatherData);

      return weather;
    } catch (e) {
      // Catch exceptions from the API service or the fromJson factory
      print('Error in WeatherRepository: $e'); // Optional: Log the error
      // Rethrow a more specific or generic exception for the BLoC layer to handle
      throw Exception('Failed to fetch and process weather data: $e');
    }
  }
}
