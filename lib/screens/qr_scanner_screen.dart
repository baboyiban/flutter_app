import 'package:flutter/material.dart';
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
        title: const Text('QR 코드 스캐너'),
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
                  : Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 100,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isCameraActive ? 'QR 코드를 스캔해주세요' : '스캔 버튼을 눌러 시작하세요',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(
                      _isCameraActive ? Icons.stop : Icons.qr_code_scanner,
                    ),
                    label: Text(_isCameraActive ? '스캔 중지' : 'QR 스캔 시작'),
                    onPressed: _toggleCamera,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
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
