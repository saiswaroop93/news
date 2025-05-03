import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import BLoC components
import '../blocs/weather/weather_bloc.dart';
import '../blocs/weather/weather_event.dart';
import '../blocs/weather/weather_state.dart';

// Import Repository, Service, and NetworkManager for direct instantiation
import '../repositories/weather_repository.dart';
import '../services/weather_api_service.dart';
import '../core/network/network_manager.dart';
// Weather model might be implicitly used via WeatherLoaded state, but good to have if needed directly
// import '../models/weather_model.dart';

/// A screen that displays weather information using WeatherBloc.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  // Hardcoded coordinates for fetching weather (e.g., Berlin)
  final double _latitude = 52.52;
  final double _longitude = 13.41;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      // Provide the WeatherBloc to the widget tree below
      body: BlocProvider(
        // Instantiate the BLoC and its dependencies directly here
        // In a real app, use a proper DI solution (get_it, provider, etc.)
        create: (context) => WeatherBloc(
          WeatherRepository(
            WeatherApiService(
              NetworkManager(),
            ),
          ),
        ),
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            // Button to trigger fetching weather
            final fetchButton = ElevatedButton(
              onPressed: () {
                // Add the FetchWeather event to the BLoC
                context.read<WeatherBloc>().add(
                      FetchWeather(latitude: _latitude, longitude: _longitude),
                    );
              },
              child: const Text('Fetch Weather'),
            );

            // Build UI based on the current state
            if (state is WeatherInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Press button to fetch weather'),
                    const SizedBox(height: 16),
                    fetchButton,
                  ],
                ),
              );
            } else if (state is WeatherLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is WeatherLoaded) {
              // Display the loaded weather data
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Weather for $_latitude, $_longitude'),
                    Text('Time: ${state.weather.time}'),
                    Text('Temperature: ${state.weather.temperature}°C'),
                    Text('Wind Speed: ${state.weather.windSpeed} km/h'),
                    const SizedBox(height: 16),
                    fetchButton, // Allow refreshing
                  ],
                ),
              );
            } else if (state is WeatherError) {
              // Display the error message
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    fetchButton, // Allow retrying
                  ],
                ),
              );
            } else {
              // Should not happen, but handle unexpected states
              return const Center(child: Text('Unknown weather state'));
            }
          },
        ),
      ),
    );
  }
}
