import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Button extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final bool isActive;

  const Button({
    super.key,
    required this.text,
    required this.color,
    this.padding,
    this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? color : AppColors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: padding ?? EdgeInsets.all(16),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.text,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
