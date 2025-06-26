import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'button.dart';

class ScanControlButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onPressed;

  const ScanControlButton({
    super.key,
    required this.isScanning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: IntrinsicWidth(
        child: Button(
          text: isScanning ? '중지' : '스캔',
          backgroundColor: AppColors.blue,
          onPressed: onPressed,
          isActive: !isScanning,
        ),
      ),
    );
  }
}
