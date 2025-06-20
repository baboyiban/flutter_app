import 'package:flutter/material.dart';
import 'package:flutter_app/app_config.dart';
import 'package:flutter_app/constants/app_colors.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';

class Vehicle {
  final int internalId;
  final String vehicleId;
  final int currentLoad;
  final int maxLoad;
  final String ledStatus;
  final bool needsConfirmation;
  final int coordX;
  final int coordY;

  Vehicle({
    required this.internalId,
    required this.vehicleId,
    required this.currentLoad,
    required this.maxLoad,
    required this.ledStatus,
    required this.needsConfirmation,
    required this.coordX,
    required this.coordY,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      internalId: json['internal_id'],
      vehicleId: json['vehicle_id'],
      currentLoad: json['current_load'],
      maxLoad: json['max_load'],
      ledStatus: json['led_status'],
      needsConfirmation: json['needs_confirmation'],
      coordX: json['coord_x'],
      coordY: json['coord_y'],
    );
  }
}

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final Logger _logger = Logger('VehiclePage');
  List<Vehicle> vehicles = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    fetchVehicles(); // Initial fetch
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchVehicles();
    });
  }

  Future<void> fetchVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/api/vehicle/1000'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          vehicles = [Vehicle.fromJson(data)];
        });
      } else {
        _logger.warning('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching vehicles: $e');
    }
  }

  Widget _buildStatusIndicator(String status) {
    Color backgroundColor;
    switch (status) {
      case '노랑':
        backgroundColor = AppColors.yellow;
      case '빨강':
        backgroundColor = AppColors.red;
      case '초록':
        backgroundColor = AppColors.green;
      default:
        backgroundColor = AppColors.gray;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📦 현재 수량: ${vehicles.isNotEmpty ? "${vehicles[0].currentLoad}/${vehicles[0].maxLoad}" : "..."}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🚚 차량 상태: ', style: const TextStyle(fontSize: 16)),
              vehicles.isNotEmpty
                  ? _buildStatusIndicator(vehicles[0].ledStatus)
                  : Text('...', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '🚀 현재 위치: ${vehicles.isNotEmpty ? "(${vehicles[0].coordX}, ${vehicles[0].coordY})" : "..."}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
