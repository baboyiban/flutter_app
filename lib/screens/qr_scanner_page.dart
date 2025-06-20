import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../widgets/qr_scanner_view.dart';
import '../widgets/scan_control_button.dart';
import '../widgets/scan_result_display.dart';

final String apiUrl = dotenv.env['API_URL']!;

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
  bool _isProcessing = false;

  final Map<String, String> zoneMap = {
    '서울': 'S',
    '경기': 'K',
    '경북': 'W',
    '강원': 'G',
  };

  // 스캔 시작/종료 토글
  void _toggleScan() {
    setState(() {
      isScanning = !isScanning;
      result = isScanning ? 'QR 코드를 스캔 중...' : '버튼을 눌러 스캔을 시작하세요';
      if (isScanning) {
        controller?.resumeCamera();
      } else {
        controller?.pauseCamera();
      }
    });
  }

  // 스캔 결과 처리
  Future<void> _sendScanResult(String scannedData) async {
    if (_isProcessing) return;
    _isProcessing = true;

    // 1. 스캔 전 차량 상태 확인
    try {
      final String vehicleApiUrl = '$apiUrl/api/vehicle/1000';
      final vehicleResponse = await http
          .get(Uri.parse(vehicleApiUrl))
          .timeout(const Duration(seconds: 5));

      if (vehicleResponse.statusCode == 200) {
        final vehicleData = jsonDecode(vehicleResponse.body);
        final int currentLoad = vehicleData['current_load'];
        final int maxLoad = vehicleData['max_load'];

        if (currentLoad >= maxLoad) {
          setState(() => result = '차량이 가득 찼습니다. 스캔할 수 없습니다.');
          _isProcessing = false;
          return; // API 요청 차단
        }
      } else {
        throw Exception('차량 상태 확인 실패');
      }
    } catch (e) {
      setState(() => result = '차량 상태 확인 오류: ${e.toString()}');
      _isProcessing = false;
      return;
    }

    // 2. 차량에 여유가 있을 경우 데이터 전송
    const String packageApiUrl = 'https://choidaruhan.xyz/api/package';
    try {
      final parts = scannedData.split('\n');
      if (parts.length < 2) throw Exception('올바르지 않은 QR 형식: [지역]\n[패키지 타입] 필요');

      final regionId = zoneMap[parts[0]];
      if (regionId == null) throw Exception('알 수 없는 지역: ${parts[0]}');

      final response = await http
          .post(
            Uri.parse(packageApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'package_type': parts[1],
              'region_id': regionId,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        setState(() => result = '등록 완료: ${parts[0]}, ${parts[1]}');
      } else {
        throw Exception(
          jsonDecode(response.body)['error'] ?? 'Failed to create record',
        );
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QRScannerView(
                  key: const ValueKey('qr_view'),
                  isScanning: isScanning,
                  qrKey: qrKey,
                  onViewCreated: _onQRViewCreated,
                ),
                const SizedBox(height: 8),
                ScanControlButton(
                  isScanning: isScanning,
                  onPressed: _toggleScan,
                ),
              ],
            ),
          ),
        ),
        ScanResultDisplay(result: result),
      ],
    );
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
