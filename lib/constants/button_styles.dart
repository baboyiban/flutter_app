import 'package:flutter/material.dart';
import 'package:flutter_app/constants/colors.dart';

class AppButtonStyles {
  static final ButtonStyle button = ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(16.0),
    elevation: 0,
    backgroundColor: AppColors.blue,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
