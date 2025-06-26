import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/constants/app_colors.dart';

class VehicleCallButton extends StatelessWidget {
  final VoidCallback onPressed;
  const VehicleCallButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: "차량 호출",
      widthType: CustomButtonWidthType.fitContent,
      backgroundColor: AppColors.blue,
    );
  }
}
