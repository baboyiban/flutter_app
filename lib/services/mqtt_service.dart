import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MqttService {
  late final MqttServerClient _client;
  bool _connected = false;

  final String host;
  final int port;
  final String clientId;
  final bool useWebSocket;

  MqttService({
    required this.host,
    required this.port,
    required this.clientId,
    this.useWebSocket = false,
  }) {
    _client = MqttServerClient.withPort(host, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

    if (useWebSocket) {
      _client.useWebSocket = true;
      _client.websocketProtocols = MqttClientConstants.protocolsMultipleDefault;
    }
  }

  Future<void> connect() async {
    if (_connected) return;
    try {
      await _client.connect();
      _connected = true;
    } catch (e) {
      rethrow;
    }
  }

  void subscribe(
    String topic,
    MqttQos qos,
    void Function(List<MqttReceivedMessage<MqttMessage?>>?) handler,
  ) {
    _client.subscribe(topic, qos);
    _client.updates?.listen(handler);
  }

  void publish(String topic, MqttQos qos, Uint8Buffer payload) {
    _client.publishMessage(topic, qos, payload);
  }

  void disconnect() {
    _client.disconnect();
    _connected = false;
  }
}
