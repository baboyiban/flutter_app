import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../widgets/qr_scanner_view.dart';
import '../widgets/scan_control_button.dart';
import '../widgets/scan_result_display.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey();
  QRViewController? controller;
  String result = '버튼을 눌러 스캔을 시작하세요';
  bool isScanning = false;
  StreamSubscription<Barcode>? _scanSubscription;
  bool _isProcessing = false; // 추가: 중복 처리 방지

  final Map<String, String> zoneMap = {
    '서울': 'S',
    '경기': 'K',
    '경북': 'W',
    '강원': 'G',
  };

  Future<void> _sendScanResult(String scannedData) async {
    if (_isProcessing) return; // 이미 처리 중이면 무시
    _isProcessing = true;

    const String apiUrl = 'https://choidaruhan.xyz/api/package';
    try {
      final parts = scannedData.split('\n');
      if (parts.length < 2) {
        throw Exception('Invalid QR format: [Region]\n[PackageType] expected');
      }

      final regionId = zoneMap[parts[0]];
      if (regionId == null) {
        throw Exception('Unknown region: ${parts[0]}');
      }

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'package_type': parts[1],
              'region_id': regionId,
              'timestamp': DateTime.now().toIso8601String(), // 추가: 고유성 보장
            }),
          )
          .timeout(const Duration(seconds: 5));

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        setState(() => result = '등록 완료: ${parts[0]}, ${parts[1]}');
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to create record');
      }
    } catch (e) {
      setState(
        () => result = '오류: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QRScannerView(
                key: const ValueKey('qr_view'),
                isScanning: isScanning,
                qrKey: qrKey,
                onViewCreated: _onQRViewCreated,
              ),
              ScanControlButton(isScanning: isScanning, onPressed: _toggleScan),
            ],
          ),
        ),
        ScanResultDisplay(result: result),
      ],
    );
  }

  void _toggleScan() {
    setState(() {
      isScanning = !isScanning;
      if (isScanning) {
        result = 'QR 코드를 스캔 중...';
        controller?.resumeCamera();
      } else {
        result = '버튼을 눌러 스캔을 시작하세요';
        controller?.pauseCamera();
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    _scanSubscription?.cancel();
    _scanSubscription = controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && isScanning && !_isProcessing) {
        setState(() {
          isScanning = false;
          result = '처리 중...';
        });
        await _sendScanResult(scanData.code!);
        controller.pauseCamera();
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    controller?.dispose();
    super.dispose();
  }
}
