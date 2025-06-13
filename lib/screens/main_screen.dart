import 'package:flutter/material.dart';
import '../constants/screen_type.dart';
import '../widgets/top_label_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'qr_scanner_page.dart';
import 'package_page.dart';
import 'vehicle_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      body: SafeArea(
        child: Column(
          children: [
            const TopLabelBar(),
            Expanded(child: _buildCurrentScreen()),
            CustomBottomNavigationBar(
              currentScreen: currentScreen,
              onScreenChanged: _changeScreen,
            ),
          ],
        ),
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
