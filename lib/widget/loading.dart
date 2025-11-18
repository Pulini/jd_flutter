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
        BackButtonInterceptor.add(myInterceptor);
        // 保持显示直到手动关闭
        final completer = Completer();
        _currentCompleter = completer;
        await completer.future;
      },
      loadingWidget: _LoadingOverlay(text, (state) => _overlayState = state),
    );
  }
  void _updateText(String? text) {
    debugPrint('_updateText  $text');
    // 直接调用 state 的更新方法
    _overlayState?._updateText(text);
  }
  void dismiss() {
    if(!_isShowing)return;
    BackButtonInterceptor.remove(myInterceptor);
    _currentCompleter?.complete();
    _overlayState=null;
    _isShowing = false;
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("-----BACK BUTTON intercepted by Loading-----");
    // 当loading显示时，完全拦截返回键，不执行任何操作
    return _isShowing;
  }
}

class LoadingSingleton {
  static final LoadingSingleton _instance = LoadingSingleton._internal();

  factory LoadingSingleton() => _instance;

  LoadingSingleton._internal();

  OverlayEntry? _overlayEntry;
  _LoadingOverlayState? _overlayState;

  bool get isShowing => _overlayEntry != null;

  void show(String? text) {
    if (_overlayEntry != null) {
      // 如果已经显示，则更新文本
      _updateText(text);
      return;
    }
    BackButtonInterceptor.add(myInterceptor);
    _overlayEntry = OverlayEntry(
      builder: (_) => _LoadingOverlay(text, (state) => _overlayState = state),
    );
    // Navigator.of(Get.overlayContext!).overlay?.insert(_overlayEntry!);
    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }

  void _updateText(String? text) {
    debugPrint('_updateText  $text');
    // 直接调用 state 的更新方法
    _overlayState?._updateText(text);
  }

  void dismiss() {
    if (isShowing) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;
      BackButtonInterceptor.remove(myInterceptor);
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("-----BACK BUTTON intercepted by Loading-----");
    // 当loading显示时，完全拦截返回键，不执行任何操作
    return isShowing;
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

  // 提供一个方法来更新文本
  void _updateText(String? text) {
    if (_currentText != text && mounted) {
      setState(() {
        _currentText = text;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgColor,
            builder: (bc, w) => Container(color: _bgColor.value),
          ),
          Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 15),
                  Text(_currentText ?? '')
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void deactivate() {
    _ctrl.reverse();
    super.deactivate();
  }
}
