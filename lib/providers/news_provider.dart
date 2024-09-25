import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsProvider extends ChangeNotifier {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final String _apiKey = '4a676cc845834c34a11c49412e33a4e2';

  List<dynamic> _news = [];
  String? _errorMessage;
  String countryCode = 'us';

  List<dynamic> get news => _news;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNews() async {
    try {
      await _remoteConfig.setDefaults({'country_code': 'in'});
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.fetchAndActivate();
      countryCode = _remoteConfig.getString('userCountryCode');
      print('countryCode value is :');
      print(countryCode);

      final String url =
          'https://newsapi.org/v2/top-headlines?country=$countryCode&apiKey=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        _news = json['articles'];
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load news';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}
