import 'package:equatable/equatable.dart';
import '../../models/weather_model.dart'; // Adjust path as needed

/// Base class for all weather-related states.
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

/// Initial state, before any weather data is fetched.
class WeatherInitial extends WeatherState {}

/// State indicating that weather data is currently being fetched.
class WeatherLoading extends WeatherState {}

/// State indicating that weather data has been successfully loaded.
class WeatherLoaded extends WeatherState {
  final Weather weather;

  /// Creates a [WeatherLoaded] state with the fetched [weather] data.
  const WeatherLoaded(this.weather);

  @override
  List<Object> get props => [weather];
}

/// State indicating that an error occurred while fetching weather data.
class WeatherError extends WeatherState {
  final String message;

  /// Creates a [WeatherError] state with the [message] describing the error.
  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}
