// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/button_styles.dart';
import '../widgets/qr_view_widget.dart';
import 'result_screen.dart'; // ResultScreen import 추가

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isCameraActive = false;
  bool _isProcessing = false;

  void _toggleCamera() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isCameraActive = !_isCameraActive;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isProcessing = false);
  }

  void _handleQRScanned(String result) {
    setState(() => _isCameraActive = false);

    // ResultScreen으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(qrResult: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isCameraActive)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {}, // QRViewWidget에서 플래시 제어
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: _isCameraActive
                  ? QRViewWidget(onQRScanned: _handleQRScanned)
                  : Center(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    label: Text(_isCameraActive ? '중지' : '스캔'),
                    onPressed: _toggleCamera,
                    style: AppButtonStyles.button,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
