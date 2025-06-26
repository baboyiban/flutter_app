import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const CustomAlertDialog({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.white,
    this.borderRadius = 8,
    this.contentPadding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
    );
  }
}
