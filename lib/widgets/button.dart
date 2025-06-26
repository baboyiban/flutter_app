import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonWidthType { fitContent, fullWidth }

class Button extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final bool isActive;
  final ButtonWidthType widthType;
  final double textSize;

  const Button({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = AppColors.text,
    this.padding,
    this.onPressed,
    this.isActive = true,
    this.widthType = ButtonWidthType.fitContent,
    this.textSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      decoration: BoxDecoration(
        color: isActive ? backgroundColor : AppColors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: textSize,
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );

    final button = InkWell(
      onTap: isActive ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: buttonContent,
    );

    if (widthType == ButtonWidthType.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else {
      return button;
    }
  }
}
