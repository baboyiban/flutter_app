import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';

class ConfirmedCard extends StatelessWidget {
  final String message;
  const ConfirmedCard({super.key, this.message = '확인되었습니다!'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
