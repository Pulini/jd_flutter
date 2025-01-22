import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttUtil {
  /// MQTT客户端
  late MqttServerClient client;

  /// MQTT服务器地址
  String server;

  /// MQTT服务器端口
  int port;

  /// MQTT订阅主题
  String topic;

  /// MQTT消息监听
  Function(String) listener = (data) {};

  MqttUtil({
    required this.server,
    required this.port,
    required this.topic,
    required this.listener,
  });

  connect() async {
    client = MqttServerClient.withPort(server, 'flutter', port);

    client.logging(on: true);

    // client.keepAlivePeriod = 60;
    // 设置连接回调
    client.onConnected = () {
      print('连接成功，订阅主题');
      client.subscribe(topic, MqttQos.atMostOnce);
    };

    // 设置断开连接回调
    client.onDisconnected = () {
      print('断开连接MQTT Broker');
    };

    //设置订阅回调
    client.onSubscribed = (String topic) {
      print('已订阅: $topic');
      client.published?.listen((MqttPublishMessage message) {
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print('接收到订也号：${message.variableHeader?.topicName} 的推送: $payload');
        listener.call(payload);
      });
    };

    // 设置取消订阅回调
    client.onUnsubscribed = (String? topic) {
      print('取消订阅: $topic');
    };

    try {
      print('连接MQTT');
      await client.connect();
    } catch (e) {
      print('MQTT连接失败: $e');
      client.disconnect();
    }
  }

  disconnect() {
    client.disconnect();
  }
}
