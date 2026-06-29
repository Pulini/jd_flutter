import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient(
  String server,
  String webSocketServer,
  int port,
  int webSocketPort,
  String clientId,
) {
  return MqttServerClient.withPort(server, clientId, port);
}
