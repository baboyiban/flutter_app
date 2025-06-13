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
  bool _isProcessing = false;
  bool _isVehicleFull = false; // 추가: 차량이 가득 찼는지 여부

  final Map<String, String> zoneMap = {
    '서울': 'S',
    '경기': 'K',
    '경북': 'W',
    '강원': 'G',
  };

  Future<void> _fetchVehicleStatus() async {
    const String vehicleApiUrl = 'https://choidaruhan.xyz/api/vehicle/1000';
    try {
      final response = await http
          .get(Uri.parse(vehicleApiUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final int currentLoad = responseBody['current_load'];
        final int maxLoad = responseBody['max_load'];

        setState(() {
          _isVehicleFull = currentLoad >= maxLoad;
          if (_isVehicleFull) {
            result = '차량이 가득 찼습니다. 스캔할 수 없습니다.';
          }
        });
      } else {
        throw Exception('Failed to fetch vehicle status');
      }
    } catch (e) {
      setState(
        () => result =
            '차량 상태 확인 중 오류: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> _sendScanResult(String scannedData) async {
    if (_isProcessing || _isVehicleFull) return; // 차량이 가득 찼으면 무시
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
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        setState(() => result = '등록 완료: ${parts[0]}, ${parts[1]}');
        await _fetchVehicleStatus(); // 스캔 후 차량 상태 다시 확인
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
  void initState() {
    super.initState();
    _fetchVehicleStatus(); // 초기 차량 상태 확인
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
              ScanControlButton(
                isScanning: isScanning,
                onPressed: _isVehicleFull
                    ? () {}
                    : _toggleScan, // Use empty function instead of null
              ),
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
      if (scanData.code != null &&
          isScanning &&
          !_isProcessing &&
          !_isVehicleFull) {
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
