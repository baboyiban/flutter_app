import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR 코드 스캐너',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캐너')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScanner()),
            );
          },
          child: const Text('QR 코드 스캔 시작'),
        ),
      ),
    );
  }
}

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔 중'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('스캔 결과: ${result!.code}')
                  : const Text('QR 코드를 스캔해주세요'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blueAccent,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카메라 권한이 없습니다')));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
