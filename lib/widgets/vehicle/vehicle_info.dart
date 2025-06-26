import 'package:flutter/material.dart';
import 'package:flutter_app/models/vehicle.dart';
import 'package:flutter_app/widgets/vehicle/vehicle_status_indicator.dart';

class VehicleInfo extends StatelessWidget {
  final Vehicle? vehicle;
  const VehicleInfo({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    if (vehicle == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📦 현재 수량: ...', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🚚 차량 상태: ', style: const TextStyle(fontSize: 16)),
              Text('...', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text('🚀 현재 위치: ...', style: const TextStyle(fontSize: 16)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📦 현재 수량: ${vehicle!.currentLoad}/${vehicle!.maxLoad}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🚚 차량 상태: ', style: const TextStyle(fontSize: 16)),
            VehicleStatusIndicator(status: vehicle!.ledStatus),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '🚀 현재 위치: (${vehicle!.coordX}, ${vehicle!.coordY})',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
