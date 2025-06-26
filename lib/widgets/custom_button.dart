import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CustomButtonWidthType { fitContent, fullWidth }

class CustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final bool isActive;
  final CustomButtonWidthType widthType;
  final double textSize;

  const CustomButton({
    super.key,
    this.text = '',
    this.backgroundColor = AppColors.deepGray,
    this.textColor = AppColors.text,
    this.padding,
    this.onPressed,
    this.isActive = true,
    this.widthType = CustomButtonWidthType.fitContent,
    this.textSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      decoration: BoxDecoration(
        color: isActive ? backgroundColor : AppColors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center, // 텍스트 중앙 정렬
      padding: padding ?? const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

    final button = InkWell(
      onTap: isActive ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: buttonContent,
    );

    if (widthType == CustomButtonWidthType.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else {
      return button;
    }
  }
}
