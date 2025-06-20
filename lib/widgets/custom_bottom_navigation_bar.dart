import 'package:flutter/material.dart';
import '../constants/screen_type.dart';
import '../constants/app_colors.dart';
import 'button.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final ScreenType currentScreen;
  final Function(ScreenType) onScreenChanged;
  final VoidCallback? onLogout;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentScreen,
    required this.onScreenChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildNavButton('QR', ScreenType.qr),
          const SizedBox(width: 4),
          _buildNavButton('차량', ScreenType.vehicle),
          const SizedBox(width: 4),
          _buildNavButton('택배', ScreenType.parcel),
          const SizedBox(width: 4),
          Expanded(
            child: Button(
              text: '로그아웃',
              color: AppColors.red,
              onPressed: onLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, ScreenType type) {
    return Expanded(
      child: Button(
        text: text,
        color: currentScreen == type ? AppColors.blue : AppColors.deepGray,
        onPressed: () => onScreenChanged(type),
      ),
    );
  }
}
