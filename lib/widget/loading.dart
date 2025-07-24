import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingSingleton {
  static final LoadingSingleton _instance = LoadingSingleton._internal();

  factory LoadingSingleton() => _instance;

  LoadingSingleton._internal();

  OverlayEntry? _overlayEntry;

  bool get isShowing => _overlayEntry != null;

  void show(String? text) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => _LoadingOverlay(text),
    );
    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }

  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay(this.content);

  final String? content;

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.black54, // 最终背景色
    ).animate(_ctrl);
    _ctrl.forward();
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
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 仅背景动画
            AnimatedBuilder(
              animation: _bgColor,
              builder: (bc, w) => Container(color: _bgColor.value),
            ),
            // Loading 本身不透明
            Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 15),
                    Text(widget.content ?? '')
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    _ctrl.reverse(); // 淡出
    super.deactivate();
  }
}
