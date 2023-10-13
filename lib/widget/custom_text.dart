import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///数字输入框 ios端添加 done 按钮
class NumberTextField extends StatefulWidget {
  final TextEditingController numberController;
  final InputDecoration decoration;
  final TextStyle textStyle;
  final int maxLength;

  const NumberTextField(
      {super.key,
      required this.numberController,
      required this.maxLength,
      required this.textStyle,
      required this.decoration});

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  OverlayEntry? _overlayEntry;
  final FocusNode _numberFocusNode = FocusNode();

  Widget doneButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      right: 0.0,
      left: 0.0,
      child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: CupertinoButton(
                padding:
                    const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Text('key_board_done'.tr,
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          )),
    );
  }

  ///显示done键
  showOverlay() {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => doneButton(context));
    overlayState.insert(_overlayEntry!);
  }

  ///移除 done 键
  removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void initState() {
    super.initState();

    if (GetPlatform.isIOS) {
      //ios 端添加监听
      _numberFocusNode.addListener(() {
        if (_numberFocusNode.hasFocus) {
          showOverlay();
        } else {
          removeOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      controller: widget.numberController,
      focusNode: _numberFocusNode,
      decoration: widget.decoration,
      maxLength: widget.maxLength,
    );
  }
}

class EditText extends StatelessWidget {
  const EditText({super.key, required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            left: 10,
            right: 10,
          ),
          filled: true,
          fillColor: Colors.grey[300],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => controller.clear(),
          ),
        ),
      ),
    );
  }
}

class TextContainer extends StatelessWidget {
  const TextContainer({
    super.key,
    required this.text,
    this.borderColor,
    this.backgroundColor,
    this.width,
    this.height,
  });

  final Widget text;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey),
        color: backgroundColor ?? Colors.transparent,
      ),
      alignment: Alignment.centerLeft,
      child: text,
    );
  }
}

/// 跑马灯 Builder 类型
typedef MarqueeWidgetBuilder = Widget Function(BuildContext context, int index, BoxConstraints constraints);

/// 跑马灯
class MarqueeWidget extends StatefulWidget {
  /// 跑马灯
  MarqueeWidget({
    Key? key,
    this.title,
    this.controller,
    this.duration = const Duration(milliseconds: 350),
    this.durationOffset = 30,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.edgeBuilder,
  }) : super(key: key);

  String? title;

  int itemCount;
  /// item builder
  MarqueeWidgetBuilder itemBuilder;
  /// 边界(前后新增) builder
  MarqueeWidgetBuilder edgeBuilder;
  /// item 间距 builder
  MarqueeWidgetBuilder separatorBuilder;
  /// 控制器
  ScrollController? controller;
  /// 定时器运行间隔
  Duration? duration;
  /// 定时器运行间隔移动偏移量
  double? durationOffset;

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget>{
  ScrollController? _scrollController;

  final _globalKey = GlobalKey();

  // final offset = ValueNotifier(0.0);

  Timer? _timer;

  @override
  void initState() {
    _scrollController = widget.controller ?? ScrollController();
    _initTimer();
    super.initState();
  }

  @override
  void dispose() {
    _cancelTimer();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return Container();
    }

    final totalCount = widget.itemCount + 2;

    return LayoutBuilder(
        builder: (context, constraints) {
          return ListView.separated(
            key: _globalKey,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(0),
            itemCount: totalCount,
            // cacheExtent: 10,
            itemBuilder: (context, index) {
              // return widget.itemBuilder(context, index, constraints);
              final isEdge = (index == 0 || index == totalCount - 1);
              if (isEdge) {
                return widget.edgeBuilder(context, index, constraints);
              }
              return widget.itemBuilder(context, index - 1, constraints);
            },
            separatorBuilder: (context, index) {
              if (index == 0 || index == totalCount - 2) {
                return Container();
              }
              return widget.separatorBuilder(context, index, constraints);
            },
          );
        }
    );
  }

  /// 取消定时器
  _cancelTimer({bool isContinue = false}) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      if (isContinue){
        _initTimer();
      }
    }
  }

  /// 初始化定时任务
  _initTimer() {
    if (_timer == null) {
      final duration = widget.duration ?? const Duration(milliseconds: 350);
      _timer = Timer.periodic(duration, (t) {
        if (_scrollController == null) {
          return;
        }
        final val = _scrollController!.offset + (widget.durationOffset ?? 30);
        _scrollController!.animateTo(val, duration: duration, curve: Curves.linear);
        if(_scrollController!.position.outOfRange){
          // print("atEdge:到边界了");
          _scrollController!.jumpTo(0);
        }
      });
    }
  }
}

