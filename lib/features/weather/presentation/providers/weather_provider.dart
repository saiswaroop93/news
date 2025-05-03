import 'package:flutter/material.dart';
import '../../domain/services/weather_service.dart'; // Adjust import path as needed
import '../../data/models/weather_model.dart';     // Adjust import path as needed

/// A ViewModel/Provider using ChangeNotifier to manage weather state
/// and interact with the WeatherService.
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;

  /// Creates a [WeatherProvider].
  ///
  /// Requires a [WeatherService] instance.
  WeatherProvider({required WeatherService weatherService})
      : _weatherService = weatherService;

  // Private state variables
  bool _isLoading = false;
  WeatherModel? _weather;
  String? _errorMessage;

  // Public getters for state variables
  bool get isLoading => _isLoading;
  WeatherModel? get weather => _weather;
  String? get errorMessage => _errorMessage;

  /// Fetches the current weather for the given coordinates and updates the state.
  Future<void> fetchWeather(double latitude, double longitude) async {
    // Start loading, clear previous error, and notify listeners
    _isLoading = true;
    _errorMessage = null;
    // Notify immediately to show loading indicator
    // Do not notify *before* setting loading=true and error=null
    notifyListeners();

    try {
      print('WeatherProvider: Fetching weather for $latitude, $longitude');
      // Call the domain service to get weather data
      final fetchedWeather = await _weatherService.getCurrentWeather(latitude, longitude);
      _weather = fetchedWeather; // Update weather data on success
      print('WeatherProvider: Successfully fetched weather: $_weather');
    } catch (e) {
      // Handle errors from the service/repository layers
      print('WeatherProvider: Error fetching weather - $e');
      _errorMessage = 'Failed to fetch weather. Please try again. Error: ${e.toString()}'; // Set a user-friendly error message
      _weather = null; // Clear previous weather data on error
    } finally {
      // Ensure loading state is turned off regardless of success or failure
      _isLoading = false;
      // Notify listeners about the final state (data/error and loading finished)
      notifyListeners();
    }
  }

  /// Optional: Method to clear the weather data and error message
  void clearWeather() {
    _weather = null;
    _errorMessage = null;
    _isLoading = false; // Ensure loading is also reset
    notifyListeners();
  }
}
