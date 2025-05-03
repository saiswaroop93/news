import 'package:dio/dio.dart';
import '../../../../core/network/network_manager.dart'; // Adjust import path if necessary
import '../models/weather_model.dart'; // Adjust import path if necessary

// Define custom exceptions if needed (optional for now)
// class ServerException implements Exception {}
// class NetworkException implements Exception {}

/// Abstract class defining the contract for fetching remote weather data.
abstract class WeatherRemoteDataSource {
  /// Fetches the current weather for the given [latitude] and [longitude].
  ///
  /// Throws a [DioException] if the request fails at the network level.
  /// Throws a [FormatException] if the response JSON is invalid.
  Future<WeatherModel> getCurrentWeather(double latitude, double longitude);
}

/// Implementation of [WeatherRemoteDataSource] using [NetworkManager].
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final NetworkManager networkManager;

  WeatherRemoteDataSourceImpl({required this.networkManager});

  /// The base URL for the Open-Meteo forecast API.
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<WeatherModel> getCurrentWeather(double latitude, double longitude) async {
    final queryParameters = {
      'latitude': latitude,
      'longitude': longitude,
      'current': 'temperature_2m,wind_speed_10m', // Request specific current fields
    };

    try {
      print('Fetching weather data from: $_baseUrl with params: $queryParameters');
      // Make the GET request using NetworkManager
      final responseData = await networkManager.get(
        _baseUrl,
        queryParameters: queryParameters,
      );

      print('Received response data: $responseData');

      // Check if responseData is Map<String, dynamic> before parsing
      if (responseData is Map<String, dynamic>) {
        // Parse the JSON response into a WeatherModel
        return WeatherModel.fromJson(responseData);
      } else {
        // Handle cases where response is not the expected type
        print('Error: Unexpected response format: ${responseData?.runtimeType}');
        // In a real app, throw a specific exception like ServerException
        throw FormatException('Unexpected response format from server.');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, status codes, etc.)
      print('DioError caught in data source: ${e.message}');
      // Optionally, map DioException types to custom exceptions
      // if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
      //   throw NetworkException();
      // } else if (e.response != null) {
      //   // Handle non-2xx status codes
      //   throw ServerException();
      // }
      rethrow; // Re-throw the DioException for now
    } on FormatException catch (e) {
       // Handle JSON parsing errors specifically
       print('FormatException caught during JSON parsing: ${e.message}');
       // In a real app, throw a specific exception like ServerException
       rethrow; // Re-throw the FormatException
    } catch (e) {
      // Handle any other unexpected errors
      print('Unexpected error caught in data source: $e');
      // In a real app, throw a generic exception or a specific custom one
      rethrow; // Re-throw the unexpected error
    }
  }
}
