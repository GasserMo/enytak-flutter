import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/personalRegestraion.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginSignup extends StatelessWidget {
  const LoginSignup({super.key});

  @override
  Widget build(BuildContext context) {
    // Store screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image covering the whole screen
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Image.asset(
              "assets/images/clean-medical-background_53876-97927.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Container(
                      height: screenHeight * 0.2,
                      width: screenHeight * 0.4,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/Enayatak.png"),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Title Text
                    Text(
                      "Let's get Started!",
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        color: const Color.fromARGB(211, 14, 13, 13),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Subtitle Text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        "Login to enjoy the features we've provided, and stay healthy",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: const Color.fromARGB(211, 14, 13, 13),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // Login Button
                    SizedBox(
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const Login()));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: const Color.fromARGB(255, 3, 190, 150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Login Button
                    SizedBox(
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const PersonalRegistrationPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: const Color.fromARGB(255, 3, 190, 150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Signup Button
                    // SizedBox(
                    //   height: screenHeight * 0.06,
                    //   width: screenWidth * 0.7,
                    //   child: OutlinedButton(
                    //     onPressed: () {
                    //       Navigator.pushNamed(context, '/MainScreen');
                    //     },
                    //     style: OutlinedButton.styleFrom(
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(30),
                    //         ),
                    //         side: const BorderSide(color: Colors.black12),
                    //         backgroundColor: Colors.teal),
                    //     child: Text(
                    //       "Continue as Guest",
                    //       style: GoogleFonts.poppins(
                    //         fontSize: 18.sp,
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
