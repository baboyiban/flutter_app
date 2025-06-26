import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttEmergencyOverlay extends StatefulWidget {
  const MqttEmergencyOverlay({super.key});

  @override
  State<MqttEmergencyOverlay> createState() => _MqttEmergencyOverlayState();
}

class _MqttEmergencyOverlayState extends State<MqttEmergencyOverlay> {
  late MqttServerClient client;
  int? internalId;
  String? message;
  bool showAlert = false;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    client = MqttServerClient.withPort(
      'mqtt.choidaruhan.xyz',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      1883,
    );
    // client.useWebSocket = true;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
      client.subscribe('vehicle/emergency', MqttQos.atLeastOnce);
      client.updates?.listen(_onMessage);
    } catch (e) {
      print('MQTT connection failed: $e');
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? event) {
    final recMess = event![0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    final data = jsonDecode(payload);

    if (data['led_status'] == '빨강') {
      setState(() {
        internalId = data['internal_id'];
        message = data['message'];
        showAlert = true;
        confirmed = false;
      });
    }
  }

  void _confirm() {
    if (internalId != null) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode({'internal_id': internalId}));
      client.publishMessage(
        'vehicle/emergency/confirm',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      setState(() {
        confirmed = true;
        showAlert = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => confirmed = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showAlert && !confirmed) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [
          // 배경 클릭 차단
          AbsorbPointer(
            absorbing: true,
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
          // 경고창(버튼 포함)은 입력 허용
          Center(
            child: showAlert
                ? Card(
                    color: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
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
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '확인되었습니다!',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
