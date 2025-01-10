import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/utils/utils.dart';

///文本输入框
class EditText extends StatelessWidget {
  const EditText({
    super.key,
    this.hint,
    this.initStr = '',
    this.hasFocus = false,
    this.controller,
    this.onChanged,
  });

  final String? initStr;
  final bool hasFocus;
  final String? hint;
  final Function(String v)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initStr);
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      margin: const EdgeInsets.all(5),
      height: 40,
      child: TextField(
        controller: this.controller ?? controller,
        onChanged: (v) {
          onChanged?.call(v);
        },
        focusNode: fn,
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
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              onChanged?.call('');
              (this.controller ?? controller).clear();
            },
          ),
        ),
      ),
    );
  }
}

///数字小数输入框输入框
class NumberDecimalEditText extends StatelessWidget {
  const NumberDecimalEditText({
    super.key,
    this.hasDecimal = true,
    this.max = double.infinity,
    this.initQty = 0.0,
    this.hint,
    this.helperText,
    this.hasFocus = false,
    required this.onChanged,
    this.controller,
  });

  final String? hint;
  final String? helperText;
  final bool hasDecimal;
  final double? max;
  final double? initQty;
  final bool hasFocus;
  final Function(double) onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    var c = TextEditingController(
      text: initQty.toShowString(),
    );
    c.selection = TextSelection.fromPosition(
      TextPosition(offset: c.text.length),
    );

    if (controller != null) {
      controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: controller!.text.length),
      );
    }
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [
          hasDecimal
              ? FilteringTextInputFormatter.allow(RegExp("[0-9.]")) //数字包括小数
              : FilteringTextInputFormatter.digitsOnly,
        ],
        focusNode: fn,
        controller: controller ?? c,
        onChanged: (v) {
          if(!v.endsWith('.')){
            if (v.toDoubleTry() > max!) {
              if (controller != null) {
                controller!.text = max.toShowString();
                controller!.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller!.text.length),
                );
              } else {
                c.text = max.toShowString();
                c.selection = TextSelection.fromPosition(
                  TextPosition(offset: c.text.length),
                );
              }
              onChanged.call(max!);
            } else {
              c.text = v.toDoubleTry().toShowString();
              c.selection = TextSelection.fromPosition(
                TextPosition(offset: c.text.length),
              );
              onChanged.call(v.toDoubleTry());
            }
          }
        },
        decoration: InputDecoration(
          helperText: helperText,
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
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () =>
                controller == null ? c.clear() : controller?.clear(),
          ),
        ),
      ),
    );
  }
}

///数字输入框输入框
class NumberEditText extends StatelessWidget {
  const NumberEditText({
    super.key,
    this.hint,
    this.hasFocus = false,
    this.showClean = true,
    required this.onChanged,
    this.initQty = 0,
    this.controller,
  });

  final bool hasFocus;
  final bool showClean;
  final String? hint;
  final int? initQty;
  final Function(String) onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    var c = TextEditingController(
      text: initQty.toString(),
    );
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      child: TextField(
        focusNode: fn,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: controller ?? c,
        onChanged: onChanged,
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
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: showClean?IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => (controller ?? c).clear(),
          ):Container(),
        ),
      ),
    );
  }
}
