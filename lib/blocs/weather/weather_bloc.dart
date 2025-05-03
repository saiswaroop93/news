import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // Required for states/events base

import '../../models/weather_model.dart'; // Required for WeatherLoaded state
import '../../repositories/weather_repository.dart'; // Required for fetching data
import 'weather_event.dart'; // Import events
import 'weather_state.dart'; // Import states

/// BLoC responsible for managing weather state based on events.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _weatherRepository;

  /// Creates a [WeatherBloc].
  ///
  /// Requires a [WeatherRepository] to fetch data.
  /// Starts with the [WeatherInitial] state.
  WeatherBloc(this._weatherRepository) : super(WeatherInitial()) {
    // Register the event handler for FetchWeather events
    on<FetchWeather>(_onFetchWeather);
  }

  /// Handles the [FetchWeather] event.
  ///
  /// Emits [WeatherLoading], then tries to fetch weather data.
  /// Emits [WeatherLoaded] on success, or [WeatherError] on failure.
  Future<void> _onFetchWeather(FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading()); // Indicate loading started
    try {
      // Fetch weather data from the repository
      final Weather weather = await _weatherRepository.fetchWeather(
        event.latitude,
        event.longitude,
      );
      // Emit loaded state with the fetched data
      emit(WeatherLoaded(weather));
    } catch (e) {
      // Emit error state if fetching or parsing fails
      print('Error in WeatherBloc: $e'); // Optional: Log the error
      emit(WeatherError('Failed to fetch weather: ${e.toString()}'));
    }
  }
}
