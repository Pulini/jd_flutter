import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

class SpinnerController {
  var select = ''.obs;
  var selectIndex = 0;
  String? saveKey;
  var dataList = <String>[];
  final Function(int)? onChanged;
  final Function(int)? onSelected;

  SpinnerController({
    this.saveKey,
    required this.dataList,
    this.onChanged,
    this.onSelected,
  }) {
    selectIndex = getSave();
    select.value = dataList[selectIndex];
    onSelected?.call(selectIndex);
  }

  int getSave() {
    var select = selectIndex;
    if (saveKey != null && saveKey!.isNotEmpty) {
      var save = spGet(saveKey!);
      if (save != null && save.isNotEmpty) {
        var index = dataList.indexOf(save);
        if (index != -1) select = index;
      }
    }
    return select;
  }

  void changeSelected(String? value) {
    if (value != null && value.isNotEmpty) {
      select.value = value;
      var index = dataList.indexOf(value);
      if (index != -1) {
        selectIndex = index;
        if (saveKey != null && saveKey?.isNotEmpty == true) {
          spSave(saveKey!, value);
        }
      }
      onChanged?.call(selectIndex);
    }
  }
}

//下啦列表
class Spinner extends StatelessWidget {
  final SpinnerController controller;

  const Spinner({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() => DropdownButton<String>(
            isExpanded: true,
            value: controller.select.value,
            underline: Container(height: 0),
            onChanged: (String? value) => controller.changeSelected(value),
            items: controller.dataList
                .map<DropdownMenuItem<String>>((String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)))
                .toList(),
          )),
    );
  }
}
