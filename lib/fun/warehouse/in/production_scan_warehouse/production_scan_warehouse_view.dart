import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/in/production_scan_warehouse/production_scan_warehouse_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/production_scan_warehouse/production_scan_warehouse_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

class ProductionScanWarehousePage extends StatefulWidget {
  const ProductionScanWarehousePage({super.key});

  @override
  State<ProductionScanWarehousePage> createState() =>
      _ProductionScanWarehousePageState();
}

class _ProductionScanWarehousePageState
    extends State<ProductionScanWarehousePage> {
  final ProductionScanWarehouseLogic logic =
      Get.put(ProductionScanWarehouseLogic());
  final ProductionScanWarehouseState state =
      Get.find<ProductionScanWarehouseLogic>().state;

  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  var tecCode = TextEditingController();

  void showCustomPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          child: Dialog(
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 160,
              width: 200,
              child: Column(
                children: [
                  Text(
                    'production_scan_storage_conditions'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: NumberEditText(
                          hasFocus: true,
                          hint: 'production_scan_operator_number'.tr,
                          controller: state.peopleNumber,
                          onChanged: (s) {
                            if (s.length >= 6) {
                              logic.checkOrderInfo(number: s);
                            }
                            if (s.isEmpty) {
                              state.peopleName.value = '';
                            }
                          },
                        ),
                      ),
                      Obx(() => Text(state.peopleName.value))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (state.peopleNumber.text.isEmpty) {
                            showSnackBar(
                                title: 'shack_bar_warm'.tr,
                                message: 'production_scan_operator_number'.tr);
                          } else {
                            Navigator.of(context).pop();
                            logic.goReport();
                          }
                        },
                        child: Text('dialog_default_confirm'.tr),
                      ),
                      TextButton(
                        onPressed: () {
                          state.peopleName.value = '';
                          state.peopleNumber.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('dialog_default_cancel'.tr),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _item(BarCodeInfo code) {
    return GestureDetector(
        onLongPress: () {
          logic.deleteCode(code);
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 1, color: code.isUsed ? Colors.red : Colors.black)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code.code.toString(),
                style: TextStyle(
                    color: code.isUsed ? Colors.red.shade700 : Colors.black),
              ),
              Text(
                code.isUsed ? '已提交'.tr : '',
                style: TextStyle(
                    color: code.isUsed ? Colors.red.shade700 : Colors.red),
              ),
              Text(
                code.isHave ? 'production_scan_not_reported'.tr : '',
                style: TextStyle(
                    color: code.isUsed ? Colors.red.shade700 : Colors.red),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 30),
          child: InkWell(
            child: Text('production_scan_clear'.tr),
            onTap: () {
              askDialog(
                title: 'dialog_default_title_information'.tr,
                content: 'production_scan_clear_the_barcode'.tr,
                confirm: () {
                  logic.clearBarCodeList();
                },
              );
            },
          ),
        )
      ],
      body: EasyRefresh(
        controller: refreshController,
        header: const MaterialHeader(),
        onRefresh: () => logic.getBarCodeStatusByDepartmentID(refresh: () {
          refreshController.finishRefresh();
          refreshController.resetFooter();
        }),
        child: Column(
          children: [
            Obx(() => Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: EditText(
                        hint: 'warehouse_allocation_input'.tr,
                        controller: tecCode,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SwitchButton(
                        onChanged: (s) => state.red.value = s,
                        name: 'production_scan_red'.tr,
                        value: state.red.value,
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.barCodeList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _item(state.barCodeList[index]),
                ),
              ),
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textSpan(
                        hint: 'production_scan_scan'.tr,
                        text: state.barCodeList.length.toString(),
                      ),
                      textSpan(
                        hint: 'production_scan_tray_number'.tr,
                        text: state.palletNumber.value,
                      ),
                    ],
                  ),
                )),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'warehouse_allocation_manually_add'.tr,
                    click: () {
                      if (tecCode.text.isNotEmpty) {
                        logic.scanCode(tecCode.text);
                      }
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'production_scan_submit'.tr,
                    click: () {
                      if (logic.haveCodeData()) {
                        logic.checkCodeList(
                          success: (s) => successDialog(
                              content: s,
                              back: () {
                                showCustomPickerDialog(context);
                              }),
                          checkBack: (s) => askDialog(
                            title: '温馨提示',
                            content: '未汇报的标签有：$s',
                            confirmText: '继续提交',
                            confirm: () {
                              showCustomPickerDialog(context);
                            },
                          ),
                        );
                      } else {
                        showSnackBar(
                            title: 'shack_bar_warm'.tr,
                            message: 'production_scan_no_barcode'.tr);
                      }
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    logic.getBarCodeStatusByDepartmentID(refresh: () {});
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) {
        logic.scanCode(code);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ProductionScanWarehouseLogic>();
    super.dispose();
  }
}
