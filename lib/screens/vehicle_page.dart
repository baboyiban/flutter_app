import 'package:flutter/material.dart';
import 'package:flutter_app/app_config.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:flutter_app/widgets/custom_alert_dialog.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/services/mqtt_service.dart';
import 'package:flutter_app/models/vehicle.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final Logger _logger = Logger('VehiclePage');
  List<Vehicle> vehicles = [];
  Timer? _timer;

  late final MqttService _mqttService;
  static const _mqttHost = 'mqtt.choidaruhan.xyz';
  static const _mqttPort = 1883;
  static const _publishTopic = 'departure_A';

  @override
  void initState() {
    super.initState();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
    _mqttService = MqttService(
      host: _mqttHost,
      port: _mqttPort,
      clientId: 'vehicle_page_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    _initMqtt();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }

  Future<void> _initMqtt() async {
    try {
      await _mqttService.connect();
    } catch (e) {
      _logger.severe('MQTT connection failed: $e');
    }
  }

  void _startAutoRefresh() {
    fetchVehicles();
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

  void _callVehicle() {
    if (vehicles.isEmpty) return;
    final vehicle = vehicles[0];
    if (vehicle.currentLoad <= vehicle.maxLoad) {
      _showDepartureDialog(vehicle);
    } else {
      _sendDeparture();
    }
  }

  void _sendDeparture() {
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode({"start": true}));
    _mqttService.publish(_publishTopic, MqttQos.atLeastOnce, builder.payload!);
    _logger.info('Vehicle call message sent via MQTT');
  }

  void _showDepartureDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomAlertDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "최대 수량(${vehicle.maxLoad}) 중 ${vehicle.currentLoad} 를 적재했습니다.\n출발하시겠습니까?",
                style: const TextStyle(fontSize: 16, color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendDeparture();
                    },
                    text: '예',
                    backgroundColor: AppColors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: '아니요',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color backgroundColor;
    switch (status) {
      case '노랑':
        backgroundColor = AppColors.yellow;
        break;
      case '빨강':
        backgroundColor = AppColors.red;
        break;
      case '초록':
        backgroundColor = AppColors.green;
        break;
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
    final vehicle = vehicles.isNotEmpty ? vehicles[0] : null;
    return Center(
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📦 현재 수량: ${vehicle != null ? "${vehicle.currentLoad}/${vehicle.maxLoad}" : "..."}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🚚 차량 상태: ', style: const TextStyle(fontSize: 16)),
                vehicle != null
                    ? _buildStatusIndicator(vehicle.ledStatus)
                    : Text('...', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '🚀 현재 위치: ${vehicle != null ? "(${vehicle.coordX}, ${vehicle.coordY}) / (${vehicle.aiCoordX}, ${vehicle.aiCoordY})" : "..."}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onPressed: _callVehicle,
                  text: "차량 출발",
                  widthType: CustomButtonWidthType.fitContent,
                  backgroundColor: AppColors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
