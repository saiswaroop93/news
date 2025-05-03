/// Represents the weather data extracted from the API response.
class Weather {
  final double temperature;
  final double windSpeed;
  final String time; // Represents the time of the 'current' weather reading

  /// Creates a [Weather] instance.
  const Weather({
    required this.temperature,
    required this.windSpeed,
    required this.time,
  });

  /// Creates a [Weather] instance from a JSON map (API response).
  ///
  /// Expects the structure from the Open-Meteo API, specifically the 'current' object.
  /// Example:
  /// ```json
  /// {
  ///   "latitude": 52.52,
  ///   "longitude": 13.41,
  ///   "generationtime_ms": 0.25,
  ///   "utc_offset_seconds": 0,
  ///   "timezone": "GMT",
  ///   "timezone_abbreviation": "GMT",
  ///   "elevation": 38.0,
  ///   "current_units": {
  ///     "time": "iso8601",
  ///     "interval": "seconds",
  ///     "temperature_2m": "°C",
  ///     "wind_speed_10m": "km/h"
  ///   },
  ///   "current": {
  ///     "time": "2024-01-01T12:00",
  ///     "interval": 900,
  ///     "temperature_2m": 5.0,
  ///     "wind_speed_10m": 15.3
  ///   },
  ///   "hourly_units": { ... },
  ///   "hourly": { ... }
  /// }
  /// ```
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Access the 'current' weather data map
    final currentData = json['current'] as Map<String, dynamic>?;

    if (currentData == null) {
      // Handle cases where 'current' data is missing
      print("Warning: 'current' data missing in JSON response.");
      return const Weather(temperature: 0.0, windSpeed: 0.0, time: '');
    }

    // Extract values with null checks and type conversions
    final temp = currentData['temperature_2m'];
    final wind = currentData['wind_speed_10m'];
    final timeStr = currentData['time'] as String?;

    // Convert temperature and windSpeed to double, providing defaults if null or wrong type
    // Using double.tryParse or checking type before casting is safer
    final double temperatureValue = (temp is num) ? temp.toDouble() : 0.0;
    final double windSpeedValue = (wind is num) ? wind.toDouble() : 0.0;

    return Weather(
      temperature: temperatureValue,
      windSpeed: windSpeedValue,
      time: timeStr ?? '', // Use empty string if time is null
    );
  }

  // Optional: Add toString for easier debugging
  @override
  String toString() {
    return 'Weather(time: $time, temperature: $temperature°C, windSpeed: $windSpeed km/h)';
  }

  // Optional: Add equality and hashCode for comparisons
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          windSpeed == other.windSpeed &&
          time == other.time;

  @override
  int get hashCode => temperature.hashCode ^ windSpeed.hashCode ^ time.hashCode;
}
