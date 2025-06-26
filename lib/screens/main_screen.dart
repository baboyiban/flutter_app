import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/mqtt_emergency_overlay.dart';
import '../constants/screen_type.dart';
import '../widgets/top_label_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
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

  void _changeScreen(ScreenType type) {
    setState(() {
      currentScreen = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  onLogout: widget.onLogout,
                ),
              ],
            ),
          ),
          const MqttEmergencyOverlay(), // 오버레이가 SafeArea 바깥에 위치!
        ],
      ),
    );
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
}
