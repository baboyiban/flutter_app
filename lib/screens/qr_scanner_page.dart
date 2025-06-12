import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
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

  // 지역 코드 매핑
  final Map<String, String> zoneMap = {
    '서울': '02',
    '경기': '031',
    '경북': '054',
    '강원': '033',
  };

  Future<void> _sendScanResult(String scannedData) async {
    const String apiUrl = 'https://choidaruhan.xyz/api/package';
    try {
      // QR 코드 데이터 파싱 (예: "서울 과일" 형식)
      final List<String> parts = scannedData.split('\n');
      if (parts.length < 2) {
        throw Exception('유효하지 않은 QR 코드 데이터 형식입니다.');
      }

      final String regionName = parts[0];
      final String packageType = parts[1];
      final String? regionId = zoneMap[regionName];

      if (regionId == null) {
        throw Exception('지역 이름을 찾을 수 없습니다: $regionName');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'package_type': packageType, 'region_id': regionId}),
      );

      if (response.statusCode == 201) {
        setState(() {
          result = '전송 완료: ${scannedData.split('\n')}';
        });
      } else {
        setState(() {
          result = '전송 실패: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = '오류 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QRScannerView와 ScanControlButton을 중앙에 배치하기 위한 Expanded
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              QRScannerView(
                isScanning: isScanning,
                qrKey: qrKey,
                onViewCreated: _onQRViewCreated,
              ),
              ScanControlButton(isScanning: isScanning, onPressed: _toggleScan),
            ],
          ),
        ),
        // ScanResultDisplay를 바닥에 붙이기
        ScanResultDisplay(result: result),
      ],
    );
  }

  void _toggleScan() {
    setState(() {
      isScanning = !isScanning;
      if (!isScanning) {
        controller?.pauseCamera();
        result = '버튼을 눌러 스캔을 시작하세요';
      } else {
        result = 'QR 코드를 스캔 중...';
        controller?.resumeCamera();
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          result = '스캔 완료: ${scanData.code}';
          isScanning = false;
          controller.pauseCamera();
        });
        _sendScanResult(scanData.code!);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
