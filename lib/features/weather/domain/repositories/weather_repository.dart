import '../../data/models/weather_model.dart'; // Import the model

// Define domain-specific exceptions if needed (optional for now)
// class WeatherException implements Exception {
//   final String message;
//   WeatherException(this.message);
// }

/// Abstract class defining the contract for accessing weather data.
/// This acts as the interface between the domain and data layers.
abstract class WeatherRepository {
  /// Fetches the current weather for the given [latitude] and [longitude].
  ///
  /// May throw domain-specific exceptions (e.g., WeatherException)
  /// or rethrow exceptions from the data layer upon failure.
  Future<WeatherModel> getCurrentWeather(double latitude, double longitude);
}
