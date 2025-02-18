import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/utils/utils.dart';
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
  List<String> topic;

  /// MQTT消息监听
  Function(String, String) msgListener = (topic, data) {};

  /// 连接成功回调
  Function(MqttUtil)? connectListener = (mqtt) {};

  /// 订阅成功回调
  Function(String)? subscribedListener = (topic) {};

  MqttUtil({
    required this.server,
    required this.port,
    required this.topic,
    this.connectListener,
    this.subscribedListener,
    required this.msgListener,
  });

  send({required String topic, String? msg}) {
    var builder = MqttClientPayloadBuilder();
    if (msg != null && msg.isNotEmpty) {
      builder.addString(msg);
    }
    var message = client.publishMessage(
      topic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
    debugPrint('发送消息=$message');
  }

  connect() async {
    client = MqttServerClient.withPort(server, userInfo?.token ?? '', port);
    client.logging(on: true);
    // 设置连接回调
    client.onConnected = () {
      debugPrint('连接成功，订阅主题');
      connectListener?.call(this);
      for (var v in topic) {
        client.subscribe(v, MqttQos.atMostOnce);
      }
      client.published?.listen((MqttPublishMessage message) {
        final topic = message.variableHeader?.topicName ?? '';
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        final String decodedString = utf8.decode(payload.codeUnits);
        debugPrint('接收到订阅号：$topic 的推送: $decodedString');
        msgListener.call(topic, decodedString);
      });
    };

    // 设置断开连接回调
    client.onDisconnected = () {
      debugPrint('断开连接MQTT');
    };

    //设置订阅回调
    client.onSubscribed = (String topic) {
      subscribedListener?.call(topic);
      debugPrint('已订阅: $topic');
    };

    // 设置取消订阅回调
    client.onUnsubscribed = (String? topic) {
      debugPrint('取消订阅: $topic');
    };

    try {
      debugPrint('连接MQTT');
      await client.connect();
    } catch (e) {
      debugPrint('MQTT连接失败: $e');
      client.disconnect();
    }
  }

  disconnect() {
    client.disconnect();
  }
}
