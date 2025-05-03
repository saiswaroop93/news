import '../../data/models/weather_model.dart'; // Adjust import path if needed
import '../repositories/weather_repository.dart'; // Adjust import path if needed

// Import domain-specific exceptions if you created them (e.g., WeatherException)
// import '../repositories/weather_repository.dart';

/// A domain service (often called a Use Case) responsible for orchestrating
/// actions related to weather data.
///
/// It uses the [WeatherRepository] to interact with the data layer.
class WeatherService {
  final WeatherRepository _weatherRepository;

  /// Creates a [WeatherService].
  ///
  /// Requires a [WeatherRepository] instance.
  WeatherService({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository;

  /// Fetches the current weather for the given coordinates.
  ///
  /// Delegates the call to the [WeatherRepository].
  /// Handles potential errors from the repository layer.
  Future<WeatherModel> getCurrentWeather(double latitude, double longitude) async {
    try {
      print('WeatherService: Calling repository for current weather...');
      // Delegate the call directly to the repository
      final weather = await _weatherRepository.getCurrentWeather(latitude, longitude);
      print('WeatherService: Received weather data from repository: $weather');
      return weather;
    } catch (e) {
      // Log the error at the service level if necessary
      print('WeatherService: Error fetching current weather - $e');
      // Re-throw the exception to be handled by the presentation layer (e.g., BLoC)
      // You might wrap it in a domain-specific exception here if needed:
      // throw WeatherException('Failed to get current weather: ${e.toString()}');
      rethrow;
    }
  }
}
