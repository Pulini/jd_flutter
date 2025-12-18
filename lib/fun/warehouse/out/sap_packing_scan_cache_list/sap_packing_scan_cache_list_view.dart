import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_packing_scan_cache_list_logic.dart';
import 'sap_packing_scan_cache_list_state.dart';

class SapPackingScanCacheListPage extends StatefulWidget {
  const SapPackingScanCacheListPage({super.key});

  @override
  State<SapPackingScanCacheListPage> createState() =>
      _SapPackingScanCacheListPageState();
}

class _SapPackingScanCacheListPageState
    extends State<SapPackingScanCacheListPage> {
  final SapPackingScanCacheListLogic logic =
      Get.put(SapPackingScanCacheListLogic());
  final SapPackingScanCacheListState state =
      Get.find<SapPackingScanCacheListLogic>().state;
  var tecActualCabinet =
      TextEditingController(text: spGet(spSavePackingScanActualCabinet) ?? '');
  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: '计划船期',
    saveKey: '${RouteConfig.sapPackingScanCacheList.name}${PickerType.date}',
  );
  var opcDestination = OptionsPickerController(
    PickerType.sapDestination,
    saveKey:
        '${RouteConfig.sapPackingScanCacheList.name}${PickerType.sapDestination}',
  );
  var lopcFactoryAndWarehouse = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapPackingScanCacheList.name}${PickerType.sapFactoryWarehouse}',
  );

  void reSubmitDataInput({
    required List<SapPackingScanAbnormalInfo> submitList,
    required DateTime postingDate,
  }) {
    var cabinetList = groupBy(submitList, (v) => v.containerNumber ?? '')
        .values
        .map((v) => v[0].containerNumber ?? '')
        .toList();

    var confirmActualCabinet = tecActualCabinet.text.isEmpty
        ? cabinetList.length > 1
            ? ''
            : cabinetList[0]
        : tecActualCabinet.text;

    var dpcDate = DatePickerController(
      PickerType.date,
      buttonName: '过账日期',
      initDate: postingDate.millisecondsSinceEpoch,
      firstDate:
          DateTime(postingDate.year, postingDate.month - 1, postingDate.day),
      lastDate:
          DateTime(postingDate.year, postingDate.month + 1, postingDate.day),
    );
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('重处理'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EditText(
                  hint: '实际柜号',
                  initStr: confirmActualCabinet,
                  onChanged: (v) => confirmActualCabinet = v,
                ),
                DatePicker(pickerController: dpcDate)
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (confirmActualCabinet.isEmpty) {
                  errorDialog(content: '请填写实际柜号');
                } else {
                  logic.reSubmit(
                    actualCabinet: confirmActualCabinet,
                    postingDate: dpcDate.getDateFormatYMD(),
                    submitList: submitList,
                    refresh: () => Get.back(),
                  );
                }
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _abnormalItem(List<SapPackingScanAbnormalInfo> list) {
    double qty = list.isEmpty
        ? 0
        : list.map((v) => v.quality ?? 0).reduce((a, b) => a.add(b));
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '物料：',
                text: list.first.materialId().allowWordTruncation(),
                maxLines: 2,
              ),
              const SizedBox(width: 5),
              textSpan(
                hint: '数量：',
                text: '${qty.toShowString()}${list.first.unit}',
              ),
              Obx(() => Checkbox(
                    value: list.every((v) => v.isSelected.value),
                    onChanged: (v) => logic.selectAbnormalMaterialItem(
                      v!,
                      list.first.materialId(),
                    ),
                  ))
            ],
          ),
          for (var piece in list) ...[
            const Divider(height: 1, indent: 10, endIndent: 15),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '件ID：${piece.pieceNumber}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '日期：${piece.date}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  Obx(() => Checkbox(
                        value: piece.isSelected.value,
                        onChanged: (v) => logic.selectAbnormalPieceItem(
                          v!,
                          piece.pieceNumber ?? '',
                        ),
                      )),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<dynamic> _searchSheet() => showSheet(
        context: context,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            EditText(hint: '实际柜号', controller: tecActualCabinet),
            DatePicker(pickerController: dpcDate),
            OptionsPicker(pickerController: opcDestination),
            LinkOptionsPicker(pickerController: lopcFactoryAndWarehouse),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    logic.getAbnormalOrders(
                      plannedDate: dpcDate.getDateFormatYMD(),
                      destination: opcDestination.getPickItem().pickerId(),
                      factory:
                          lopcFactoryAndWarehouse.getPickItem1().pickerId(),
                      warehouse:
                          lopcFactoryAndWarehouse.getPickItem2().pickerId(),
                      actualCabinet: tecActualCabinet.text,
                      refresh: () => Navigator.pop(context),
                    );
                  },
                  child: Text(
                    'page_title_with_drawer_query'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        scrollControlled: true,
      );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchSheet());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(functionTitle),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchSheet(),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      placeholder: '请输入物料编号货物料描或跟踪号述进行过滤',
                      onChanged: (v) => state.abnormalSearchText.value = v,
                    ),
                  ),
                  Obx(() => Checkbox(
                        value: logic.isSelectedAllAbnormalItem(),
                        onChanged: (v) => logic.selectAllAbnormalItem(v!),
                      ))
                ],
              ),
              Expanded(
                child: Obx(() {
                  var list = logic.showAbnormalList();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) => _abnormalItem(list[i]),
                  );
                }),
              ),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => CombinationButton(
                          combination: Combination.left,
                          backgroundColor: Colors.red,
                          isEnabled: logic.selectedAbnormalItem().isNotEmpty,
                          text: '删除',
                          click: () => askDialog(
                            content: '确定要删除所选标签吗？',
                            confirm: () => logic.deleteAbnormal(),
                          ),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => CombinationButton(
                          combination: Combination.right,
                          backgroundColor: Colors.orange,
                          isEnabled: logic.selectedAbnormalItem().isNotEmpty,
                          text: '重处理',
                          click: () => logic.getReSubmitData(
                            (list, maxDate) => reSubmitDataInput(
                              postingDate: maxDate,
                              submitList: list,
                            ),
                          ),
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPackingScanCacheListLogic>();
    super.dispose();
  }
}
