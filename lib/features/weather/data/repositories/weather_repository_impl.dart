import 'package:dio/dio.dart'; // Import DioException for specific handling

import '../../domain/repositories/weather_repository.dart'; // Import the domain interface
import '../datasources/weather_remote_data_source.dart'; // Import the data source interface
import '../models/weather_model.dart'; // Import the data model

// Import domain-specific exceptions if you created them (e.g., WeatherException)
// import '../../domain/repositories/weather_repository.dart';

/// Implementation of the [WeatherRepository] interface.
///
/// This class acts as a bridge between the domain layer and the data layer (data sources).
/// It fetches data from the remote data source and handles potential errors.
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherModel> getCurrentWeather(double latitude, double longitude) async {
    try {
      // Delegate the call to the remote data source
      print('Repository: Calling remote data source for weather...');
      final weatherModel = await remoteDataSource.getCurrentWeather(latitude, longitude);
      print('Repository: Received weather model from data source: $weatherModel');
      // The remote data source already returns WeatherModel, so no mapping is needed here.
      // If the data source returned a DTO, you would map it to the domain model here.
      return weatherModel;
    } on DioException catch (e) {
      // Handle specific network/server errors from the data source
      print('Repository: Caught DioException - ${e.message}');
      // Optionally map to a domain-specific exception:
      // throw WeatherException('Failed to fetch weather data from server: ${e.message}');
      rethrow; // Re-throw the exception for the use case/bloc to handle
    } on FormatException catch (e) {
       // Handle specific parsing errors from the data source
       print('Repository: Caught FormatException - ${e.message}');
       // Optionally map to a domain-specific exception:
       // throw WeatherException('Failed to parse weather data: ${e.message}');
       rethrow; // Re-throw the exception
    } catch (e) {
      // Catch any other unexpected errors
      print('Repository: Caught unexpected error - $e');
      // Optionally map to a generic domain-specific exception:
      // throw WeatherException('An unexpected error occurred: $e');
      rethrow; // Re-throw the exception
    }
  }
}
