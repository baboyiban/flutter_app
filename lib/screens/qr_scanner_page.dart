import 'package:flutter/material.dart';
import 'package:flutter_app/app_config.dart';
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

  final Map<String, String> zoneMap = {
    '서울': 'S',
    '경기': 'K',
    '경북': 'W',
    '강원': 'G',
  };

  // 스캔 시작/종료 토글
  void _toggleScan() async {
    setState(() {
      isScanning = !isScanning;
      result = isScanning ? 'QR 코드를 스캔 중...' : '스캔이 중지되었습니다';
    });

    if (isScanning) {
      await controller?.resumeCamera();
    } else {
      await controller?.pauseCamera();
    }
  }

  // 스캔 결과 처리
  Future<void> _sendScanResult(String scannedData) async {
    setState(() {
      isScanning = false;
      _isProcessing = true;
      result = '처리 중...';
    });

    try {
      // 1. 스캔 전 차량 상태 확인
      final String vehicleApiUrl = '${AppConfig.apiUrl}/api/vehicle/1000';
      final vehicleResponse = await http
          .get(Uri.parse(vehicleApiUrl))
          .timeout(const Duration(seconds: 5));

      if (vehicleResponse.statusCode == 200) {
        final vehicleData = jsonDecode(vehicleResponse.body);
        final int currentLoad = vehicleData['current_load'];
        final int maxLoad = vehicleData['max_load'];

        if (currentLoad >= maxLoad) {
          setState(() => result = '차량이 가득 찼습니다. 스캔할 수 없습니다.');
          return;
        }
      } else {
        throw Exception('차량 상태 확인 실패');
      }

      // 2. 차량에 여유가 있을 경우 데이터 전송
      final String packageApiUrl = '${AppConfig.apiUrl}/api/package';
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
      } else if (response.statusCode == 409) {
        // 409 Conflict: 중복 데이터
        setState(() => result = '중복된 데이터입니다');
      } else if (response.statusCode == 400) {
        // 400 Bad Request: 잘못된 요청
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error']?.toString() ?? '잘못된 요청입니다';
        setState(() => result = errorMsg);
      } else {
        // 기타 에러
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error']?.toString() ?? '알 수 없는 오류';
        // 혹시 중복 메시지가 error에 포함되어 있다면 추가로 체크
        if (errorMsg.contains('Duplicate entry') || errorMsg.contains('중복')) {
          setState(() => result = '중복된 데이터입니다');
        } else {
          setState(() => result = '오류: $errorMsg');
        }
      }
    } catch (e) {
      setState(
        () => result = '오류: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QRScannerView(
                          key: const ValueKey('qr_view'),
                          isScanning: isScanning,
                          qrKey: qrKey,
                          onViewCreated: _onQRViewCreated,
                        ),
                        const SizedBox(height: 16),
                        ScanControlButton(
                          isScanning: isScanning,
                          onPressed: _toggleScan,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ScanResultDisplay(result: result),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    _scanSubscription?.cancel();
    _scanSubscription = controller.scannedDataStream.listen((scanData) async {
      // 스캔 중이 아니면 무시
      if (!isScanning || _isProcessing) return;

      if (scanData.code != null) {
        // 카메라를 먼저 멈추고, 결과 처리를 시작합니다.
        await controller.pauseCamera();
        _sendScanResult(scanData.code!);
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
