import 'package:dio/dio.dart';

class NetworkManager {
  late final Dio _dio;

  // Optional: Configure Dio instance with base options
  NetworkManager() {
    final options = BaseOptions(
      // Example: Set a base URL if you have one
      // baseUrl: 'https://api.example.com', 
      connectTimeout: Duration(seconds: 10), // 10 seconds
      receiveTimeout: Duration(seconds: 10), // 10 seconds
    );
    _dio = Dio(options);

    // Optional: Add interceptors for logging, authentication, etc.
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
      logPrint: (o) => print(o), // Ensure logs are printed
    ));
  }

  // GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      // Re-throw the exception or return a custom error object
      rethrow; 
    } catch (e) {
      print("Unexpected error: $e");
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("Unexpected error: $e");
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("Unexpected error: $e");
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("Unexpected error: $e");
      rethrow;
    }
  }

  // Helper method to handle Dio errors
  void _handleDioError(DioException e) {
    // Log the error or handle different types of errors
    print("DioError occurred:");
    print("  Type: ${e.type}");
    if (e.response != null) {
      print("  Status Code: ${e.response?.statusCode}");
      print("  Status Message: ${e.response?.statusMessage}");
      print("  Data: ${e.response?.data}");
    } else {
      print("  Error Message: ${e.message}");
    }
    // Depending on the error type, you might want to throw specific exceptions
    // or return specific error codes/messages.
  }
}
