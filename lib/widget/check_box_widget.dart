import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';

///单选框
class CheckBox extends StatefulWidget {
  final Function(bool isChecked) onChanged;
  final String name;
  final bool value;
  final bool? isEnabled;
  final bool? needSave;

  const CheckBox({
    super.key,
    required this.onChanged,
    required this.name,
    required this.value,
    this.isEnabled = true,
    this.needSave = true,
  });

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  var isChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.needSave == true) {
      var initialValue =
          spGet('${Get.currentRoute}/${widget.name}') ?? widget.value ?? false;
      if (isChecked != initialValue) {
        setState(() => isChecked = initialValue);
      }
    } else {
      isChecked = widget.value;
    }
  }

  _checked(bool checked) {
    if (widget.isEnabled == true) {
      isChecked = checked;
      if (widget.needSave == true) {
        spSave('${Get.currentRoute}/${widget.name}', isChecked);
      }
      widget.onChanged.call(isChecked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecked != widget.value) {
      isChecked = widget.value;
      if (widget.needSave == true) {
        spSave('${Get.currentRoute}/${widget.name}', isChecked);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTap: () => _checked(!isChecked),
        child: Row(
          children: [
            Checkbox(
              activeColor: widget.isEnabled == true ? Colors.blue : Colors.grey,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
              ),
              value: isChecked,
              onChanged: (v) => _checked(v!),
            ),
            Text(
              widget.name,
              style: TextStyle(
                color: widget.isEnabled == true ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}