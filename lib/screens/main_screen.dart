import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_alert_dialog.dart';
import 'package:flutter_app/widgets/confirmed_card.dart';
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
  bool showConfirmed = false;
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
        showConfirmed = false;
        dialogMessage = '정말로 로그아웃 하시겠습니까?';
      });
    }
  }

  void _onConfirmLogout() {
    setState(() {
      showDialog = false;
      showConfirmed = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showConfirmed = false);
        widget.onLogout?.call();
      }
    });
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
          if (showDialog || showConfirmed)
            CustomAlertDialog(
              child: showConfirmed
                  ? const ConfirmedCard()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dialogMessage),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _onCancelDialog,
                              child: const Text('아니요'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _onConfirmLogout,
                              child: const Text('예'),
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
