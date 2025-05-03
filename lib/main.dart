import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/providers/auth_provider.dart';
import 'package:news/providers/news_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Core
import 'package:news/core/network/network_manager.dart';
// Weather Feature Imports
import 'package:news/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:news/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:news/features/weather/domain/services/weather_service.dart';
import 'package:news/features/weather/presentation/providers/weather_provider.dart';
import 'package:news/features/weather/presentation/screens/weather_screen.dart';

// Old screen import (can be removed if LoginScreen is no longer the entry point)
import 'package:news/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Instantiate dependencies for Weather feature
    // In a larger app, consider using a proper dependency injection framework (like get_it)
    final networkManager = NetworkManager();
    final remoteDataSource = WeatherRemoteDataSourceImpl(networkManager: networkManager);
    final weatherRepository = WeatherRepositoryImpl(remoteDataSource: remoteDataSource);
    final weatherService = WeatherService(weatherRepository: weatherRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        // Add the WeatherProvider
        ChangeNotifierProvider(create: (_) => WeatherProvider(weatherService: weatherService)),
      ],
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'News App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              // Change home to WeatherScreen
              home: const WeatherScreen(),
            );
          }),
    );
  }
}
