import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bluetooth() {
  Size size = MediaQuery.of(Get.overlayContext!).size;

  var popup = Container(
    padding: const EdgeInsets.all(8.0),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      gradient: LinearGradient(
        colors: [Colors.lightBlueAccent, Colors.blueAccent],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '连接蓝牙',
          style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              decoration: TextDecoration.none),
        ),
        const SizedBox(height: 30),
        Container(
          width: size.width - 20,
          height: 330,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 20, right: 20),
          // child: LoginInlet(logic: logic, state: state),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(size.width - 20, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => {Get.back()},
          child: Text(
            '搜索',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    ),
  );
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    barrierDismissible: false,
    builder: (BuildContext context) => PopScope(
      //拦截返回键
      canPop: false,
      child: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: popup,
      ),
    ),
  );
}
