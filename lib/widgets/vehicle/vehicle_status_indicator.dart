import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';

class VehicleStatusIndicator extends StatelessWidget {
  final String status;
  const VehicleStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    switch (status) {
      case '노랑':
        backgroundColor = AppColors.yellow;
        break;
      case '빨강':
        backgroundColor = AppColors.red;
        break;
      case '초록':
        backgroundColor = AppColors.green;
        break;
      default:
        backgroundColor = AppColors.gray;
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
