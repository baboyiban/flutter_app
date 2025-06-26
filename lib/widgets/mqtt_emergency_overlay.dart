import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_app/constants/app_colors.dart';
import 'package:flutter_app/services/mqtt_service.dart';
import 'package:flutter_app/widgets/custom_alert_dialog.dart';
import 'package:flutter_app/widgets/confirmed_card.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_dropdown_button.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttEmergencyOverlay extends StatefulWidget {
  const MqttEmergencyOverlay({super.key});

  @override
  State<MqttEmergencyOverlay> createState() => _MqttEmergencyOverlayState();
}

class _MqttEmergencyOverlayState extends State<MqttEmergencyOverlay> {
  static const _mqttHost = 'mqtt.choidaruhan.xyz';
  static const _mqttPort = 1883;
  static const _subscribeTopic = 'vehicle/emergency';
  static const _publishTopic = 'vehicle/emergency/confirm';
  static const _employeeId = 4;

  late final MqttService _mqttService;
  String? _vehicleId;
  String? _message;
  bool _showAlert = false;
  bool _confirmed = false;

  final List<String> _reasons = ["차량 관련 호출", "택배 관련 호출", "운송 관련 호출"];
  final Map<String, int> _reasonToNumber = {
    "차량 관련 호출": 1,
    "택배 관련 호출": 2,
    "운송 관련 호출": 3,
  };
  String _selectedReason = "차량 관련 호출";

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService(
      host: _mqttHost,
      port: _mqttPort,
      clientId: 'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      useWebSocket: kIsWeb,
    );
    _initMqtt();
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  Future<void> _initMqtt() async {
    try {
      await _mqttService.connect();
      _mqttService.subscribe(
        _subscribeTopic,
        MqttQos.atLeastOnce,
        _handleMqttMessage,
      );
      debugPrint('Subscribed to $_subscribeTopic');
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
    }
  }

  void _handleMqttMessage(List<MqttReceivedMessage<MqttMessage?>>? event) {
    debugPrint('MQTT message received: $event');
    if (event == null || event.isEmpty) return;
    final recMess = event[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    debugPrint('Payload: $payload');
    final data = jsonDecode(payload);

    if (data['led_status'] == '하양') {
      setState(() {
        _vehicleId = data['vehicle_id'];
        _message = data['message'];
        _showAlert = true;
        _confirmed = false;
      });
    }
  }

  void _confirm() {
    if (_vehicleId == null) return;
    final builder = MqttClientPayloadBuilder();
    final reasonNumber = _reasonToNumber[_selectedReason] ?? 0;
    builder.addString(
      jsonEncode({
        "vehicle_id": _vehicleId,
        "reason": reasonNumber,
        "employee_id": _employeeId,
      }),
    );
    _mqttService.publish(_publishTopic, MqttQos.atLeastOnce, builder.payload!);

    setState(() {
      _confirmed = true;
      _showAlert = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _confirmed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAlert && !_confirmed) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: true,
            child: Container(color: Colors.black.withAlpha(50)),
          ),
          Center(
            child: _showAlert
                ? CustomAlertDialog(
                    backgroundColor: AppColors.red,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _message ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownButton(
                          items: _reasons,
                          value: _selectedReason,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedReason = value);
                            }
                          },
                          backgroundColor: AppColors.white,
                          borderRadius: 8,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(color: AppColors.black),
                          dropdownColor: AppColors.white,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              onPressed: _confirm,
                              text: '🚨 확인',
                              backgroundColor: AppColors.darkRed,
                              textColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const ConfirmedCard(),
          ),
        ],
      ),
    );
  }
}
