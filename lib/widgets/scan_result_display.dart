import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ScanResultDisplay extends StatelessWidget {
  final String result;

  const ScanResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Text(result, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
