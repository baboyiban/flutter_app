import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final bool? initialFlashState;

  const QRViewWidget({
    super.key,
    required this.onQRScanned,
    this.initialFlashState = false,
  });

  @override
  State<QRViewWidget> createState() => _QRViewWidgetState();
}

class _QRViewWidgetState extends State<QRViewWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // QR 스캐너 뷰
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.blueAccent,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: _getScanAreaSize(context),
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),

        // 플래시 토글 버튼
        if (_isCameraInitialized)
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black54,
              onPressed: _toggleFlash,
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // 플래시 상태 초기화
    controller.getFlashStatus().then((status) {
      if (mounted) {
        setState(() {
          _isFlashOn = status ?? false;
          _isCameraInitialized = true;
        });
      }
    });

    // 스캔 결과 리스너
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        widget.onQRScanned(scanData.code!);
        controller.pauseCamera();
      }
    });
  }

  void _toggleFlash() async {
    try {
      await controller?.toggleFlash();
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카메라 권한이 없습니다')));
    }
  }

  double _getScanAreaSize(BuildContext context) {
    return (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
