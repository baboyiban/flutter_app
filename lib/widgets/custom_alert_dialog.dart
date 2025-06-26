import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final bool dimBackground; // 추가: 어두운 배경 여부
  final Color dimColor; // 추가: 배경 색상

  const CustomAlertDialog({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.white,
    this.borderRadius = 8,
    this.contentPadding = const EdgeInsets.all(16),
    this.dimBackground = true,
    this.dimColor = const Color.fromRGBO(0, 0, 0, 0.5),
  });

  @override
  Widget build(BuildContext context) {
    Widget dialog = Center(
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(padding: contentPadding, child: child),
      ),
    );

    if (!dimBackground) return dialog;

    return Stack(
      children: [
        Positioned.fill(
          child: AbsorbPointer(
            absorbing: true,
            child: Container(color: dimColor),
          ),
        ),
        dialog,
      ],
    );
  }
}
