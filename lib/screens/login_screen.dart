import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/appcolors.dart';
import 'package:news/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'news_screen.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool _obscureText = true;

    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 170.h,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: AppColors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
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
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 20.h),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: AppColors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
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
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
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
                            CircularProgressIndicator()
                          else
                            Padding(
                              padding: EdgeInsets.only(left: 35.w, right: 35.w),
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    authProvider
                                        .signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    )
                                        .then((_) {
                                      if (authProvider.user != null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => NewsScreen()),
                                        );
                                      }
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
                                      "Login",
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
                          if (authProvider.errorMessage != null)
                            Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SignupScreen()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'New here? ',
                                style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Poppins'),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Signup',
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
