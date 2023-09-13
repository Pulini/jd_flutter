import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import '../../http/response/picker_item.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    Key? key,
    required this.pickerController,
  }) : super(key: key);
  final DatePickerController pickerController;

  _showOptions() {
    var now = DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: pickerController.pickDate.value,
      //起始时间
      firstDate: pickerController.firstDate ??
          DateTime(now.year - 1, now.month, now.day),
      //最小可以选日期
      lastDate: pickerController.lastDate ??
          DateTime(now.year, now.month, now.day + 7), //最大可选日期
    ).then((date) {
      if (date != null) {
        pickerController.select(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pickerController.getDateFormatYMD(),
                style: const TextStyle(color: Colors.black),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      pickerController.enable.value ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showOptions(),
                child: Text(
                  pickerController.buttonName ??
                      pickerController.getButtonName(),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          )),
    );
  }
}

var _titleButtonCancel = TextButton(
  onPressed: () => Get.back(),
  child: Text(
    'dialog_default_cancel'.tr,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 20,
    ),
  ),
);

class OptionsPicker extends StatelessWidget {
  const OptionsPicker({
    Key? key,
    required this.pickerController,
  }) : super(key: key);

  final OptionsPickerController pickerController;

  _showOptions() {
    if (pickerController.enable.value == false) return;
    if (pickerController.pickerItems.isNotEmpty) {
      //创建选择器控制器
      var controller = FixedExtentScrollController(
        initialItem: pickerController.getSave(),
      );

      var titleSearch = Expanded(
        child: CupertinoSearchTextField(
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
          placeholder: 'picker_search'.tr,
          onChanged: (String value) => pickerController.search(value),
        ),
      );

      var titleButtonConfirm = TextButton(
        onPressed: () {
          if (pickerController.pickerItems.isEmpty) return;
          pickerController.select(controller.selectedItem);
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
                  _titleButtonCancel,
                  titleSearch,
                  titleButtonConfirm,
                ],
              ),
            ),
            Obx(() => Expanded(
                  child: getCupertinoPicker(
                    pickerController.pickerItems.map((data) {
                      return Center(child: Text(data.pickerName()));
                    }).toList(),
                    controller,
                  ),
                )),
          ],
        ),
      );
    } else {
      pickerController.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    pickerController.search('');
    pickerController.getData();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Expanded(
                child: AutoSizeText(
                  pickerController.loadingError.isEmpty
                      ? pickerController.selectedName.value
                      : pickerController.loadingError.value,
                  style: const TextStyle(color: Colors.black),
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 16,
                ),
              )),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pickerController.pickerItems.isEmpty
                      ? Colors.red
                      : pickerController.enable.value
                          ? Colors.blue
                          : Colors.grey,
                  foregroundColor: pickerController.pickerItems.isEmpty
                      ? Colors.orange
                      : Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showOptions(),
                child: Text(
                  pickerController.pickerItems.isNotEmpty
                      ? pickerController.buttonName ??
                          pickerController.getButtonName()
                      : 'picker_refresh'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }
}

class LinkOptionsPicker extends StatelessWidget {
  const LinkOptionsPicker({
    Key? key,
    required this.pickerController,
  }) : super(key: key);
  final LinkOptionsPickerController pickerController;

  Widget _pickerText(PickerItem data) {
    return Text(
      data.pickerName(),
      style: TextStyle(fontSize: data.pickerName().length > 10 ? 12 : 16),
    );
  }

  _showOptions() {
    if (pickerController.enable.value == false) return;
    if (pickerController.pickerItems1.isNotEmpty) {
      var select = pickerController.getSave();
      //创建选择器控制器
      var controller1 = FixedExtentScrollController(initialItem: select[0]);
      var controller2 = FixedExtentScrollController(initialItem: select[1]);

      var titleSearch = Expanded(
        child: CupertinoSearchTextField(
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
          placeholder: 'picker_search'.tr,
          onChanged: (String value) => pickerController.search(value),
        ),
      );

      var titleButtonConfirm = TextButton(
        onPressed: () {
          if (pickerController.pickerItems1.isEmpty) return;
          pickerController.select(
              controller1.selectedItem, controller2.selectedItem);
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
                  _titleButtonCancel,
                  titleSearch,
                  titleButtonConfirm,
                ],
              ),
            ),
            Obx(() => Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: controller1,
                          onSelectedItemChanged: (value) {
                            pickerController.refreshItem2(value);
                            controller2.jumpToItem(0);
                          },
                          itemExtent: 22,
                          squeeze: 1.2,
                          children: pickerController.pickerItems1.map((data) {
                            return _pickerText(data);
                          }).toList(),
                        ),
                      ),
                      Expanded(
                          child: CupertinoPicker(
                        scrollController: controller2,
                        onSelectedItemChanged: (value) {},
                        itemExtent: 22,
                        squeeze: 1.2,
                        children: pickerController.pickerItems2.map((data) {
                          return _pickerText(data);
                        }).toList(),
                      )),
                    ],
                  ),
                )),
          ],
        ),
      );
    } else {
      pickerController.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    pickerController.search('');
    pickerController.getData();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Expanded(
                child: AutoSizeText(
                  pickerController.loadingError.isEmpty
                      ? pickerController.selectedName.value
                      : pickerController.loadingError.value,
                  style: const TextStyle(color: Colors.black),
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 16,
                ),
              )),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pickerController.pickerItems2.isEmpty
                      ? Colors.red
                      : pickerController.enable.value
                          ? Colors.blue
                          : Colors.grey,
                  foregroundColor: pickerController.pickerItems2.isEmpty
                      ? Colors.orange
                      : Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showOptions(),
                child: Text(
                  pickerController.pickerItems2.isNotEmpty
                      ? pickerController.buttonName ??
                          pickerController.getButtonName()
                      : 'picker_refresh'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }
}

class Spinner extends StatelessWidget {
  final SpinnerController controller;

  const Spinner({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
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
