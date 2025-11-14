import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

//数字输入框 ios端添加 done 按钮
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

//ios适配专用输入法
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

  //显示done键
  void showOverlay() {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => doneButton(context));
    overlayState.insert(_overlayEntry!);
  }

  //移除 done 键
  void removeOverlay() {
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: widget.numberController,
      focusNode: _numberFocusNode,
      decoration: widget.decoration,
      maxLength: widget.maxLength,
    );
  }
}