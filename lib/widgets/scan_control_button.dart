import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class ScanControlButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback? onPressed;

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
        child: CustomButton(
          text: isScanning ? '중지' : '스캔',
          backgroundColor: !isScanning ? AppColors.blue : AppColors.red,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
