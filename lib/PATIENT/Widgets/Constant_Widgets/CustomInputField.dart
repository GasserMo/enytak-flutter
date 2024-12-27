import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  final VoidCallback? onTap;
  final String? hintText;
  final double? height;
  final String? errorText; // New property for error messages

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.icon,
    this.onTap,
    this.hintText,
    this.height,
    this.errorText,
    required InputDecoration inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textAlign: TextAlign.start,
        textInputAction: TextInputAction.none,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          focusColor: Colors.black26,
          fillColor: const Color.fromARGB(255, 247, 247, 247),
          filled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icon),
          ),
          prefixIconColor: const Color.fromARGB(255, 3, 190, 150),
          labelText: labelText,
          labelStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
            color: const Color.fromARGB(255, 37, 37, 37),
          ),
          hintText: hintText,
          errorText: errorText, // Show error text if provided

          hintStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
            color: const Color.fromARGB(255, 37, 37, 37),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: height ?? 20,
            horizontal: 15,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
