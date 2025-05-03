import 'package:http/http.dart' as http;
import 'dart:async'; // Import for async/await and Future
import 'dart:io'; // Import for SocketException

/// A manager class to handle network requests.
class NetworkManager {
  /// Fetches data from the given [url] using an HTTP GET request.
  ///
  /// Throws an [Exception] if the request fails or the status code is not 200.
  Future<String> getData(Uri url) async {
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successfully fetched data
        return response.body;
      } else {
        // Server returned an error status code
        throw Exception(
            'Failed to load data from $url - Status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Handle specific network errors like no internet connection
      throw Exception('Network error: Failed to connect to $url. ${e.message}');
    } on TimeoutException catch (e) {
      // Handle request timeout errors
      throw Exception('Network timeout: Request to $url timed out. ${e.message}');
    } catch (e) {
      // Handle any other exceptions during the request
      throw Exception('An unexpected error occurred while fetching data from $url: $e');
    }
  }
}
