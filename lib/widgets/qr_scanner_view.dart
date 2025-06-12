import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatelessWidget {
  final bool isScanning;
  final GlobalKey qrKey;
  final Function(QRViewController) onViewCreated;

  const QRScannerView({
    super.key,
    required this.isScanning,
    required this.qrKey,
    required this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: isScanning
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: QRView(key: qrKey, onQRViewCreated: onViewCreated),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
    );
  }
}
