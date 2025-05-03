import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Adjust import paths based on your project structure
import '../providers/weather_provider.dart';
import '../../data/models/weather_model.dart'; // Needed for type casting if displaying model directly

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  // Hardcoded coordinates for Berlin (as used in API example)
  static const double _latitude = 52.52;
  static const double _longitude = 13.41;

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen to changes in WeatherProvider
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: _buildWeatherContent(context, weatherProvider),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use context.read inside callbacks/event handlers
          context.read<WeatherProvider>().fetchWeather(_latitude, _longitude);
        },
        tooltip: 'Fetch Weather',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherProvider provider) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    } else if (provider.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: ${provider.errorMessage}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (provider.weather != null) {
      final weather = provider.weather!; // Safe access after null check
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Current Weather',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Temperature: ${weather.temperature.toStringAsFixed(1)}°C', // Example formatting
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Wind Speed: ${weather.windSpeed.toStringAsFixed(1)} km/h', // Example formatting
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      );
    } else {
      // Initial state or after clearing
      return const Text(
        'Press the refresh button to fetch weather data.',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
  }
}
