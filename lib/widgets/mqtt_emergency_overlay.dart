import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom_dropdown_button.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

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

  late final MqttServerClient _client;
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
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    _client =
        MqttServerClient.withPort(
            _mqttHost,
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
            _mqttPort,
          )
          ..logging(on: false)
          ..keepAlivePeriod = 20
          ..connectionMessage = MqttConnectMessage()
              .withClientIdentifier(
                'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
              )
              .startClean()
              .withWillQos(MqttQos.atLeastOnce);

    try {
      await _client.connect();
      _client.subscribe(_subscribeTopic, MqttQos.atLeastOnce);
      _client.updates?.listen(_handleMqttMessage);
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
    }
  }

  void _handleMqttMessage(List<MqttReceivedMessage<MqttMessage?>>? event) {
    if (event == null || event.isEmpty) return;
    final recMess = event[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
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
      '{"vehicle_id":"$_vehicleId","reason":$reasonNumber,"employee_id":$_employeeId}',
    );
    _client.publishMessage(
      _publishTopic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

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
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          Center(child: _showAlert ? _buildAlertCard() : _buildConfirmedCard()),
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return Card(
      color: AppColors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _message ?? '',
              style: const TextStyle(fontSize: 16, color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              textStyle: const TextStyle(color: AppColors.black),
              dropdownColor: AppColors.white,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  onPressed: _confirm,
                  text: "🚨 확인",
                  textColor: AppColors.white,
                  backgroundColor: AppColors.darkRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  widthType: ButtonWidthType.fitContent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '확인되었습니다!',
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
