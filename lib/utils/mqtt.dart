import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttUtil {
  //是否自动重连
  var isAutoReconnect = false;

  // MQTT客户端
  late MqttServerClient client;

  // MQTT服务器地址
  String server;

  // MQTT服务器端口
  int port;

  // MQTT订阅主题
  List<String> topic;

  // MQTT消息监听
  Function(String, String) msgListener = (topic, data) {};

  // 连接成功回调
  Function(MqttUtil)? connectListener = (mqtt) {};

  // 订阅成功回调
  Function(String)? subscribedListener = (topic) {};

  MqttUtil({
    required this.server,
    required this.port,
    required this.topic,
    this.connectListener,
    this.subscribedListener,
    required this.msgListener,
  }) {
    initClient();
  }

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

  initClient() {
    client = MqttServerClient.withPort(server, userInfo?.token ?? '', port);

    // 设置日志
    client.logging(on: false);

    // 设置心跳间隔时间
    client.keepAlivePeriod = 60;

    //自动重连
    client.autoReconnect = true;

    //连接监听
    client.onConnected = () {
      debugPrint(isAutoReconnect ? '自动重连' : '初始连接');
      connectListener?.call(this);

      if (!isAutoReconnect) {
        debugPrint('订阅主题');
        for (var v in topic) {
          client.subscribe(v, MqttQos.atMostOnce);
        }

/*
        //订阅监听  *系统bug 无法监听到推送消息*
        client.published?.listen(( message) {
          final topic = message.variableHeader?.topicName ?? '';
          final payload =
              MqttPublishPayload.bytesToStringAsString(message.payload.message);
          final String decodedString = utf8.decode(payload.codeUnits);
          debugPrint('接收到订阅号：$topic 的推送: $decodedString');
          msgListener.call(topic, decodedString);
        });
*/
        //全局监听，临时替代订阅监听
        client.updates!.listen((msg) {
          for (var v in msg) {
            var data =  utf8.decode(MqttPublishPayload.bytesToStringAsString(
              (v.payload as MqttPublishMessage).payload.message,
            ).codeUnits);
            debugPrint('接收到订阅号:${v.topic} 的推送: $data');
            msgListener.call(v.topic, data);
          }
        });
      }
    };

    //自动重连执行前监听
    client.onAutoReconnect = () {
      isAutoReconnect = true;
      debugPrint('启动自动重连');
    };

    //自动重连执行后监听
    client.onAutoReconnected = () {
      // if(lastSendMsg.length==2){
      //   send(topic: lastSendMsg[0], msg: lastSendMsg[1]);
      // }else if(lastSendMsg.length==1){
      //   send(topic: lastSendMsg[0]);
      // }
      debugPrint('自动重连完成');
    };

    //断开连接监听
    client.onDisconnected = () {
      debugPrint('断开连接MQTT');
    };

    //订阅监听
    client.onSubscribed = (String topic) {
      subscribedListener?.call(topic);
      debugPrint('已订阅: $topic');
    };

    //取消订阅回调
    client.onUnsubscribed = (String? topic) {
      debugPrint('取消订阅: $topic');
    };
  }

  connect() async {
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
