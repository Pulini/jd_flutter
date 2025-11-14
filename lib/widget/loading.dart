import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingController {
  static final LoadingController _instance = LoadingController._internal();

  factory LoadingController() => _instance;

  LoadingController._internal();

  _LoadingOverlayState? _overlayState;
  bool _isShowing = false;
  static Completer? _currentCompleter;

  void show(String? text) {
    if (_isShowing) {
      _updateText(text);
      return;
    }
    _isShowing = true;
    Get.showOverlay(
      asyncFunction: () async {
        // 保持显示直到手动关闭
        final completer = Completer();
        _currentCompleter = completer;
        await completer.future;
      },
      loadingWidget: _LoadingOverlay(text, (state) => _overlayState = state),
    );
  }

  void _updateText(String? text) {
    _overlayState?._updateText(text);
  }

  void dismiss() {
    _currentCompleter?.complete();
    _overlayState = null;
    _isShowing = false;
  }
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay(this.content, this.stateSetter);

  final String? content;
  final Function(_LoadingOverlayState state) stateSetter;

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _bgColor;
  String? _currentText;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _currentText = widget.content;
    widget.stateSetter.call(this);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.black54,
    ).animate(_ctrl);
    _ctrl.forward();
  }

  void _updateText(String? text) {
    debugPrint("loading-----updateText($text)-----");
    if (_currentText != text && mounted) {
      setState(() {
        _currentText = text;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 点击背景不关闭（如果需要可添加GestureDetector拦截点击）
        AnimatedBuilder(
          animation: _bgColor,
          builder: (bc, w) => Container(
            color: _bgColor.value,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Center(
          child: Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.blue, // 优化：指定进度条颜色
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _currentText ?? '加载中...', // 优化：默认文本
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("loading-----返回键拦截-----");
    return true;
  }
  @override
  void deactivate() {
    _ctrl.reverse();
    super.deactivate();
  }
}
