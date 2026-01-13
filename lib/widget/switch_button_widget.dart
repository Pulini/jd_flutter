import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';


//选择器
class SwitchButton extends StatefulWidget {
  final Function(bool isChecked) onChanged;
  final String name;
  final bool? value;
  final bool? isEnabled;
  final bool? needSave;

  const SwitchButton({
    super.key,
    required this.onChanged,
    required this.name,
    this.value,
    this.isEnabled = true,
    this.needSave = true,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  var isChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      if (widget.needSave == true) {
        var initialValue = spGet('${Get.currentRoute}/${widget.name}') ??
            widget.value ??
            false;
        if (isChecked != initialValue) {
          isChecked = initialValue;
        }
        widget.onChanged.call(isChecked);
      }
    } else {
      isChecked = widget.value!;
    }
  }

  void _select(bool checked) {
    if (widget.isEnabled == true && isChecked != checked) {
      setState(() {
        isChecked = checked;
        widget.onChanged.call(isChecked);
        if (widget.value == null && widget.needSave == true) {
          spSave('${Get.currentRoute}/${widget.name}', isChecked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(
            widget.name,
            style: const TextStyle(color: Colors.black),
          )),
          Expanded(flex: 2,child: Switch(
            thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.check);
                }
                return const Icon(Icons.close);
              },
            ),
            value: isChecked,
            onChanged: _select,
          ),)
        ],
      ),
    );
  }
}