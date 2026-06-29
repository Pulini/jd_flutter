import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient createMqttClient(
  String server,
  String webSocketServer,
  int port,
  int webSocketPort,
  String clientId,
) {
  final wsServer = webSocketServer.startsWith('ws://') ||
          webSocketServer.startsWith('wss://')
      ? webSocketServer
      : 'ws://$webSocketServer';
  return MqttBrowserClient.withPort(wsServer, clientId, webSocketPort);
}
