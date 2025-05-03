import 'dart:convert';

class WeatherModel {
  final double temperature;
  final double windSpeed;

  const WeatherModel({
    required this.temperature,
    required this.windSpeed,
  });

  // Factory constructor to parse JSON
  // Expects a JSON structure like:
  // {
  //   "current": {
  //     "temperature_2m": 15.3,
  //     "wind_speed_10m": 10.8
  //     // ... other fields
  //   }
  //   // ... other top-level fields
  // }
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('current')) {
      throw FormatException("JSON missing 'current' key");
    }
    final currentData = json['current'] as Map<String, dynamic>?;

    if (currentData == null) {
      throw FormatException("'current' key is not a map or is null");
    }

    if (!currentData.containsKey('temperature_2m') || !currentData.containsKey('wind_speed_10m')) {
       throw FormatException("JSON missing 'temperature_2m' or 'wind_speed_10m' key under 'current'");
    }

    // Ensure values are parsed as doubles, handling potential int values
    final temp = currentData['temperature_2m'];
    final wind = currentData['wind_speed_10m'];

    return WeatherModel(
      temperature: (temp is int) ? temp.toDouble() : temp as double,
      windSpeed: (wind is int) ? wind.toDouble() : wind as double,
    );
  }

  // Factory constructor to parse a JSON string directly
  factory WeatherModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return WeatherModel.fromJson(jsonMap);
  }


  // copyWith method
  WeatherModel copyWith({
    double? temperature,
    double? windSpeed,
  }) {
    return WeatherModel(
      temperature: temperature ?? this.temperature,
      windSpeed: windSpeed ?? this.windSpeed,
    );
  }

  // Override == operator for value equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeatherModel &&
        other.temperature == temperature &&
        other.windSpeed == windSpeed;
  }

  // Override hashCode for consistency with ==
  @override
  int get hashCode => temperature.hashCode ^ windSpeed.hashCode;

  @override
  String toString() {
    return 'WeatherModel(temperature: $temperature, windSpeed: $windSpeed)';
  }
}
