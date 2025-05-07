import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/appcolors.dart';
import 'package:news/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import go_router
// import 'package:news/screens/login_screen.dart'; // No longer needed for direct navigation
// import 'news_screen.dart'; // No longer needed for direct navigation

class SignupScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignupScreen({super.key}); // Added key

  @override
  Widget build(BuildContext context) {
    bool _obscureText = true;

    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false, // Keep this if no back button is desired
          backgroundColor: AppColors.whiteshade,
          title: Text(
            'MyNews',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: AppColors.blue,
                fontSize: 24.sp),
          )),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: StatefulBuilder( // Keep StatefulBuilder for _obscureText
                builder: (context, setState) {
                  return ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100.h,
                          ),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          TextFormField(
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          TextFormField(
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() { // Use setState from StatefulBuilder
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 250.h),
                          if (authProvider.isLoading)
                            const CircularProgressIndicator() // Use const
                          else
                            Padding(
                              padding: EdgeInsets.only(left: 50.w, right: 50.w),
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    authProvider
                                        .signUp(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                      _nameController.text.trim(),
                                    )
                                        .then((_) {
                                      // Check mounted status before navigating
                                       if (context.mounted && authProvider.user != null) {
                                        context.go('/news'); // Use go_router
                                      }
                                       // Handle signup failure?
                                       // Error message is already handled below
                                    }).catchError((error) {
                                      // Optional: Handle specific errors if needed
                                      // Error message display is handled by provider state
                                    });
                                  }
                                },
                                child: Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Signup",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (authProvider.errorMessage != null && !authProvider.isLoading) // Show error only if not loading
                             Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red), // Use const
                               ),
                             ),
                          TextButton(
                            onPressed: () {
                               context.go('/login'); // Use go_router
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Poppins'),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                        color: AppColors.blue,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
