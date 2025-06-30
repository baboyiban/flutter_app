import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool dimBackground; // 추가: 어두운 배경 여부
  final Color dimColor; // 추가: 배경 색상
  final EdgeInsets margin; // 마진

  const CustomAlertDialog({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.white,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(0),
    this.dimBackground = true,
    this.dimColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.margin = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    Widget dialog = Center(
      child: Card(
        elevation: 1,
        margin: margin,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(padding: padding, child: child),
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
