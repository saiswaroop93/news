import 'package:equatable/equatable.dart';

/// Base class for all weather-related events.
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched to fetch weather data for specific coordinates.
class FetchWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  /// Creates a [FetchWeather] event.
  const FetchWeather({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}
