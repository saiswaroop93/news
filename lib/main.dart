import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:news/providers/auth_provider.dart'; // Removed
import 'package:news/screens/login_screen.dart';
// import 'package:news/providers/news_provider.dart'; // Removed
import 'firebase_options.dart';
// import 'package:provider/provider.dart'; // Removed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp())); // Wrapped with ProviderScope and added const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    // Removed MultiProvider and AuthProvider
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Task Manager App', // Updated title
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const LoginScreen(), // Added const
          );
        });
  }
}
