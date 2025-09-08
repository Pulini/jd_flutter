import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/utils/extension_util.dart';

//文本输入框
class EditText extends StatefulWidget {
  const EditText({
    super.key,
    this.hint,
    this.initStr = '',
    this.hasFocus = false,
    this.controller,
    this.onChanged,
    this.isEnable = true,
    this.hasClose = true,
  });

  final String? initStr;
  final bool hasFocus;
  final bool isEnable;
  final bool hasClose;
  final String? hint;
  final Function(String v)? onChanged;
  final TextEditingController? controller;

  @override
  State<EditText> createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  late TextEditingController _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initStr);
    if (widget.hasFocus) {
      _focusNode = FocusNode()..requestFocus();
    }
  }

  @override
  void dispose() {
    // 只有当我们自己创建controller时才需要dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      height: 40,
      child: TextField(
        enabled: widget.isEnable,
        controller: _controller,
        onChanged: (v) {
          widget.onChanged?.call(v);
        },
        focusNode: _focusNode,
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
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          labelText: widget.hint,
          labelStyle: const TextStyle(color: Colors.black54),
          suffixIcon: widget.hasClose
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    widget.onChanged?.call('');
                    _controller.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

//数字小数输入框输入框
class NumberDecimalEditText extends StatefulWidget {
  const NumberDecimalEditText({
    super.key,
    this.hasDecimal = true,
    this.max = double.infinity,
    this.initQty = 0.0,
    this.hint,
    this.helperText,
    this.hasFocus = false,
    this.resetQty = 0,
    this.onChanged,
    this.controller,
    this.inputEnable = true,
  });

  final String? hint;
  final String? helperText;
  final bool hasDecimal;
  final double? max;
  final double? initQty;
  final bool hasFocus;
  final double resetQty;
  final Function(double)? onChanged;
  final TextEditingController? controller;
  final bool? inputEnable;

  @override
  State<NumberDecimalEditText> createState() => _NumberDecimalEditTextState();
}

class _NumberDecimalEditTextState extends State<NumberDecimalEditText> {
  late TextEditingController _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initQty?.toShowString() ?? '');
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    if (widget.hasFocus) {
      _focusNode = FocusNode()..requestFocus();
    }
  }

  @override
  void dispose() {
    // 只有当我们自己创建controller时才需要dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      child: TextField(
        enabled: widget.inputEnable,
        keyboardType: TextInputType.number,
        inputFormatters: [
          widget.hasDecimal
              ? FilteringTextInputFormatter.allow(RegExp('[0-9.]')) //数字包括小数
              : FilteringTextInputFormatter.digitsOnly,
        ],
        focusNode: _focusNode,
        controller: _controller,
        onChanged: (v) {
          if (!v.endsWith('.')) {
            if (double.tryParse(v) != null && v.toDoubleTry() > widget.max!) {
              if (widget.controller != null) {
                widget.controller!.text = widget.max.toShowString();
                widget.controller!.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.controller!.text.length),
                );
              } else {
                _controller.text = widget.max.toShowString();
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              }
              widget.onChanged?.call(widget.max!);
            } else {
              if (widget.controller != null) {
                widget.controller!.text = v.toDoubleTry().toShowString();
                widget.controller!.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.controller!.text.length),
                );
              } else {
                _controller.text = v.toDoubleTry().toShowString();
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              }
              widget.onChanged?.call(v.toDoubleTry());
            }
          }
        },
        decoration: InputDecoration(
          helperText: widget.helperText,
          helperStyle: const TextStyle(color: Colors.blueAccent),
          contentPadding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            left: 10,
            right: 10,
          ),
          filled: true,
          fillColor: Colors.grey[300],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          labelText: widget.hint,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: widget.resetQty != 0
              ? IconButton(
                  onPressed: () {
                    widget.controller == null
                        ? _controller.text = widget.resetQty.toShowString()
                        : widget.controller?.text = widget.resetQty.toShowString();
                    widget.onChanged?.call(widget.resetQty);
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.blue,
                  ),
                )
              : null,
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              widget.controller == null ? _controller.clear() : widget.controller?.clear();
              widget.onChanged?.call(0);
            },
          ),
        ),
      ),
    );
  }
}

//数字输入框输入框
class NumberEditText extends StatefulWidget {
  const NumberEditText({
    super.key,
    this.hint,
    this.hasFocus = false,
    this.showClean = true,
    this.onChanged,
    this.initQty = 0,
    this.controller,
  });

  final bool hasFocus;
  final bool showClean;
  final String? hint;
  final int? initQty;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  State<NumberEditText> createState() => _NumberEditTextState();
}

class _NumberEditTextState extends State<NumberEditText> {
  late TextEditingController _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initQty.toString());
    if (widget.hasFocus) {
      _focusNode = FocusNode()..requestFocus();
    }
  }

  @override
  void dispose() {
    // 只有当我们自己创建controller时才需要dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      child: TextField(
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _controller,
        onChanged: widget.onChanged,
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
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          labelText: widget.hint,
          labelStyle: const TextStyle(color: Colors.black54),
          suffixIcon: widget.showClean
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}