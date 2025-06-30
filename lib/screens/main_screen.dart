import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:flutter_app/widgets/custom_alert_dialog.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/mqtt_emergency_overlay.dart';
import 'package:flutter_app/widgets/top_label_bar.dart';
import 'package:flutter_app/widgets/custom_bottom_navigation_bar.dart';
import '../constants/screen_type.dart';
import 'qr_scanner_page.dart';
import 'package_page.dart';
import 'vehicle_page.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const MainScreen({super.key, this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScreenType currentScreen = ScreenType.qr;
  bool showDialog = false;
  String dialogMessage = '정말로 로그아웃 하시겠습니까?';

  void _changeScreen(ScreenType type) {
    setState(() {
      currentScreen = type;
    });
  }

  void _showLogoutDialog() {
    if (!showDialog) {
      setState(() {
        showDialog = true;
        dialogMessage = '정말로 로그아웃 하시겠습니까?';
      });
    }
  }

  void _onConfirmLogout() {
    setState(() {
      showDialog = false;
    });
    widget.onLogout?.call();
  }

  void _onCancelDialog() {
    if (showDialog) {
      setState(() => showDialog = false);
    }
  }

  Widget _buildCurrentScreen() {
    switch (currentScreen) {
      case ScreenType.qr:
        return const QRScannerPage();
      case ScreenType.parcel:
        return const PackagePage();
      case ScreenType.vehicle:
        return const VehiclePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const TopLabelBar(),
                Expanded(child: _buildCurrentScreen()),
                CustomBottomNavigationBar(
                  currentScreen: currentScreen,
                  onScreenChanged: _changeScreen,
                  onLogout: _showLogoutDialog,
                ),
              ],
            ),
          ),
          if (showDialog)
            CustomAlertDialog(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dialogMessage, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        onPressed: _onConfirmLogout,
                        text: '예',
                        padding: EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        onPressed: _onCancelDialog,
                        text: '아니요',
                        backgroundColor: AppColors.red,
                        padding: EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const MqttEmergencyOverlay(),
        ],
      ),
    );
  }
}
