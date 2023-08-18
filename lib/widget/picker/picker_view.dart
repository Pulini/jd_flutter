import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../http/response/picker_item.dart';

class Picker extends StatefulWidget {
  const Picker({
    Key? key,
    this.saveKey,
    required this.buttonName,
    required this.controller,
    required this.getDataList,
  }) : super(key: key);
  final String? saveKey;
  final String buttonName;
  final PickerController controller;
  final Function getDataList;

  @override
  State<Picker> createState() => _PickerState();
}

class PickerController {
  var selectedName = ''.obs;
  var selectedId = ''.obs;
  var enable = true.obs;
  List<PickerItem> pickerData = [];
  RxList<PickerItem> pickerItems = <PickerItem>[].obs;

  select(PickerItem item) {
    selectedName.value = item.pickerName();
    selectedId.value = item.pickerId();
  }

  search(String text) {
    if (text.trim().isEmpty) {
      pickerItems.value = pickerData;
    } else {
      pickerItems.value = pickerData
          .where((element) => element.pickerName().contains(text))
          .toList();
    }
  }
}

class _PickerState extends State<Picker> {
  _showOptions() {
    if (widget.controller.enable.value == false) return;
    if (widget.controller.pickerItems.isNotEmpty) {
      var initialItem = 0;
      if (widget.saveKey != null && widget.saveKey!.isNotEmpty) {
        var find = widget.controller.pickerItems.indexWhere(
          (element) => element.pickerId() == spGet(widget.saveKey!),
        );
        if (find >= 0) initialItem = find;
      }
      //创建选择器控制器
      var controller = FixedExtentScrollController(initialItem: initialItem);

      var titleButtonCancel = TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          'dialog_default_cancel'.tr,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
      );

      var titleSearch = Expanded(
        child: CupertinoSearchTextField(
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
          placeholder: '输入名称快速定位',
          onChanged: (String value) => widget.controller.search(value),
        ),
      );

      var titleButtonConfirm = TextButton(
        onPressed: () {
          var select = widget.controller.pickerItems[controller.selectedItem];
          widget.controller.select(select);
          if (widget.saveKey != null && widget.saveKey!.isNotEmpty) {
            spSave(widget.saveKey!, select.pickerId());
          }
          Get.back();
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );

      showPopup(
        Column(
          children: [
            Container(
              height: 80,
              color: Colors.grey[200],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleButtonCancel,
                  titleSearch,
                  titleButtonConfirm,
                ],
              ),
            ),
            Obx(() => Expanded(
                  child: getCupertinoPicker(
                    widget.controller.pickerItems.map((data) {
                      return Center(child: Text(data.pickerName()));
                    }).toList(),
                    controller,
                  ),
                )),
          ],
        ),
      );
    } else {
      _getData();
    }
  }

  _getData() {
    if (widget.controller.pickerItems.isEmpty) {
      widget.getDataList().then((value) {
        if (value.isNotEmpty) {
          widget.controller.pickerData = value;
          widget.controller.pickerItems.value = value;
          var select = value[0];
          if (widget.saveKey != null && widget.saveKey!.isNotEmpty) {
            var save = spGet(widget.saveKey!);
            widget.controller.select(
              select = widget.controller.pickerItems.firstWhere(
                (element) => element.pickerId() == save,
                orElse: () => select,
              ),
            );
          }
          widget.controller.select(select);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    widget.controller.selectedName.value,
                    style: const TextStyle(color: Colors.black),
                  )),
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.controller.pickerItems.isEmpty
                          ? Colors.red
                          : widget.controller.enable.value
                              ? Colors.blue
                              : Colors.grey,
                      foregroundColor: widget.controller.pickerItems.isEmpty
                          ? Colors.orange
                          : Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _showOptions(),
                    child: Text(
                      widget.controller.pickerItems.isNotEmpty
                          ? widget.buttonName
                          : '刷新',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
