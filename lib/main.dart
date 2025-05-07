import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/providers/auth_provider.dart';
// import 'package:news/screens/login_screen.dart'; // No longer needed directly here
import 'package:news/providers/news_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:news/router.dart'; // Import the router configuration

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            // Use MaterialApp.router and provide the router configuration
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'News App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              // Remove the 'home' property
              // home: LoginScreen(),
              // Add the routerConfig property
              routerConfig: router,
            );
          }),
    );
  }
}
