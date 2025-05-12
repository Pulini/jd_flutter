import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:marquee/marquee.dart';

import 'picker_item.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({super.key, required this.pickerController});

  final DatePickerController pickerController;

  _showOptions() {
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      //起始时间
      initialDate: pickerController.pickDate.value,
      //最小可以选日期
      firstDate: pickerController.firstDate,
      //最大可选日期
      lastDate: pickerController.lastDate,
    ).then((date) {
      if (date != null) {
        pickerController.select(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10, right: 3),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getDateYMD(time: pickerController.pickDate.value),
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    backgroundColor: pickerController.enable.value
                        ? Colors.blue
                        : Colors.grey,
                    foregroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  onPressed: () => _showOptions(),
                  child: Text(
                    pickerController.buttonName ??
                        pickerController.getButtonName(),
                    style: const TextStyle(color: Colors.white),
                  ),
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
  OptionsPicker({super.key, required this.pickerController}) {
    pickerController.getData();
  }

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
          controller: TextEditingController(text:pickerController.searchText),
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
                    items: pickerController.pickerItems.map((data) {
                      return Center(child: Text(data.toShow()));
                    }).toList(),
                    controller: controller,
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
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10, right: 3),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
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
          Obx(() => SizedBox(
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    backgroundColor: pickerController.pickerItems.isEmpty
                        ? Colors.red
                        : pickerController.enable.value
                            ? Colors.blue
                            : Colors.grey,
                    foregroundColor: pickerController.pickerItems.isEmpty
                        ? Colors.orange
                        : Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
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
                ),
              ))
        ],
      ),
    );
  }
}

class LinkOptionsPicker extends StatelessWidget {
  LinkOptionsPicker({super.key, required this.pickerController}) {
    pickerController.getData();
  }

  final LinkOptionsPickerController pickerController;

  Widget _pickerText(PickerItem data) {
    return Text(
      data.toShow(),
      style: TextStyle(fontSize: data.toShow().length > 10 ? 12 : 16),
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
          controller: TextEditingController(text:pickerController.searchText),
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
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10, right: 3),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
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
          Obx(() => SizedBox(
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    backgroundColor: pickerController.pickerItems2.isEmpty
                        ? Colors.red
                        : pickerController.enable.value
                            ? Colors.blue
                            : Colors.grey,
                    foregroundColor: pickerController.pickerItems2.isEmpty
                        ? Colors.orange
                        : Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
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
                ),
              ))
        ],
      ),
    );
  }
}

class CheckBoxPicker extends StatelessWidget {
  final CheckBoxPickerController checkBoxController;

  const CheckBoxPicker({
    super.key,
    required this.checkBoxController,
  });

  _showCheckBoxList() {
    if (checkBoxController.enable.value == false) return;
    if (checkBoxController.checkboxItems.isNotEmpty) {
      checkBoxController.initSelectState();

      var titleSearch = Expanded(
        child: CupertinoSearchTextField(
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(20),
          ),
          placeholder: 'picker_search'.tr,
          onChanged: (String value) => checkBoxController.search(value),
        ),
      );

      var titleButtonConfirm = TextButton(
        onPressed: () {
          var checked = checkBoxController.checkboxItems
              .where((v) => (v as PickerMesMoldingPackArea).isChecked);
          if (checked.isEmpty) {
            showSnackBar(
                title: checkBoxController.getButtonName(),
                message: '请至少勾选一条选项');
          } else {
            checkBoxController.select();
            Get.back();
          }
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );

      var selectAll = Card(
        child: Obx(() => Checkbox(
              value: checkBoxController.isSelectAll.value,
              onChanged: (checked) =>
                  checkBoxController.refreshCheckedList(checked!),
            )),
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
                    selectAll,
                  ],
                ),
              ),
              Expanded(
                child: Obx(() => ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: checkBoxController.checkboxItems.length,
                      itemBuilder: (BuildContext context, int index) => Card(
                        child: CheckboxListTile(
                          title: Text(
                            checkBoxController.checkboxItems[index].toShow(),
                          ),
                          value: (checkBoxController.checkboxItems[index]
                                  as PickerMesMoldingPackArea)
                              .isChecked,
                          onChanged: (checked) => checkBoxController
                              .refreshCheckedItem(index, checked!),
                        ),
                      ),
                    )),
              )
            ],
          ),
          height: 300);
    } else {
      checkBoxController.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    checkBoxController.search('');
    checkBoxController.getData();
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 10, right: 3),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Expanded(
                child: SizedBox(
                  height: 40,
                  child: Marquee(
                    text: checkBoxController.loadingError.isEmpty
                        ? checkBoxController.selectedText.value
                        : checkBoxController.loadingError.value,
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 20.0,
                    // pauseAfterRound: const Duration(seconds: 1),
                  ),
                ),
              )),
          const SizedBox(width: 10),
          Obx(() => SizedBox(
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    backgroundColor: checkBoxController.checkboxItems.isEmpty
                        ? Colors.red
                        : checkBoxController.enable.value
                            ? Colors.blue
                            : Colors.grey,
                    foregroundColor: checkBoxController.checkboxItems.isEmpty
                        ? Colors.orange
                        : Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  onPressed: () => _showCheckBoxList(),
                  child: Text(
                    checkBoxController.checkboxItems.isNotEmpty
                        ? checkBoxController.buttonName ??
                            checkBoxController.getButtonName()
                        : 'picker_refresh'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
