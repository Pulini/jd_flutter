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
  late final List<DropdownMenuItem<String>> _items;

  SpinnerController({
    this.saveKey,
    required this.dataList,
    this.onChanged,
    this.onSelected,
  }) {
    _items = dataList
        .map<DropdownMenuItem<String>>(
            (v) => DropdownMenuItem<String>(value: v, child: Text(v)))
        .toList(growable: false);
    // 空列表保护：未保存任何历史时下拉无选项，避免 dataList[0] 越界
    if (dataList.isEmpty) {
      select.value = '';
      selectIndex = 0;
      return;
    }
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
    // 空数据时不渲染 DropdownButton（value 无法匹配空 items），显示占位
    if (controller.dataList.isEmpty) {
      return Container(
        height: 40,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(left: 10, right: 5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('—', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
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
            underline: const SizedBox.shrink(),
            onChanged: (String? value) => controller.changeSelected(value),
            items: controller._items,
          )),
    );
  }
}
