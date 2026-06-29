import 'package:mqtt_client/mqtt_client.dart';

MqttClient createMqttClient(
  String server,
  String webSocketServer,
  int port,
  int webSocketPort,
  String clientId,
) {
  throw UnsupportedError('MQTT is not supported on this platform');
}
