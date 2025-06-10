import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// 공통 색상 정의
class AppColors {
  static const Color blue = Color(0xFFBFDFFF);
  static const Color gray = Color(0xFFEFEFEF);
  static const Color deepGray = Color(0xFFDFDFDF);
  static const Color red = Color(0xFFFFBFBF);
  static const Color text = Colors.black;
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: QRScannerScreen());
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey();
  QRViewController? controller;
  String result = '버튼을 눌러 스캔을 시작하세요';
  bool isScanning = false;

  void _toggleScan() {
    setState(() {
      isScanning = !isScanning;
      if (!isScanning) {
        controller?.pauseCamera();
        result = '버튼을 눌러 스캔을 시작하세요'; // 추가: 스캔 중지 시 메시지 초기화
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 라벨 영역
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Label(text: '직원 A'),
                  SizedBox(width: 4),
                  Label(text: '차량 B'),
                ],
              ),
            ),
            // QR 스캐너 영역 + 제어 버튼 그룹
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // QR 스캐너 영역
                    SizedBox(
                      width: 256,
                      height: 256,
                      child: isScanning
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: QRView(
                                key: qrKey,
                                onQRViewCreated: _onQRViewCreated,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                    ),
                    // 스캔 제어 버튼
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Button(
                        text: isScanning ? '중지' : '스캔',
                        color: AppColors.blue,
                        onPressed: _toggleScan,
                        isActive: !isScanning,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 스캔 결과 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: double.infinity,
                height: 80, // 고정 높이 160px
                decoration: BoxDecoration(
                  color: AppColors.deepGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  // 스크롤 추가
                  child: Text(result, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
            // 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Button(text: 'QR', color: AppColors.blue),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Button(text: '택배', color: AppColors.gray),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Button(text: '택배차', color: AppColors.gray),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Button(text: '로그아웃', color: AppColors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// 라벨 위젯
class Label extends StatelessWidget {
  final String text;
  const Label({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepGray,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    );
  }
}

/// 버튼 커스텀 위젯
class Button extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final Color? disabledColor;
  final bool isActive; // 추가: 활성화 상태 여부

  const Button({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
    this.padding,
    this.disabledColor,
    this.isActive = true, // 기본값 true
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : AppColors.red, // 상태에 따라 색상 변경
        disabledBackgroundColor: disabledColor ?? color,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.text,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
