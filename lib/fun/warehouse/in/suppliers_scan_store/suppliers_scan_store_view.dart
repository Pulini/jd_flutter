import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/in/suppliers_scan_store/suppliers_scan_store_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/suppliers_scan_store/suppliers_scan_store_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

class SuppliersScanStorePage extends StatefulWidget {
  const SuppliersScanStorePage({super.key});

  @override
  State<SuppliersScanStorePage> createState() => _SuppliersScanStorePageState();
}

class _SuppliersScanStorePageState extends State<SuppliersScanStorePage> {
  final SuppliersScanStoreLogic logic = Get.put(SuppliersScanStoreLogic());
  final SuppliersScanStoreState state =
      Get.find<SuppliersScanStoreLogic>().state;

  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  var tecCode = TextEditingController();

  GestureDetector _item(BarCodeInfo code) {
    return GestureDetector(
        onLongPress: () {
          askDialog(
              content: 'suppliers_scan_delete_code'.tr,
              confirm: () {
                logic.deleteCode(code);
              });
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.black)),
          child: Text(code.code.toString()),
        ));
  }

  void showCustomPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          child: Dialog(
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 270,
              width: 200,
              child: Column(
                children: [
                   Text(
                    'suppliers_scan_storage_conditions'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  DatePicker(pickerController: logic.orderDate),
                  OptionsPicker(
                      pickerController: logic.billStockListController),
                  Row(
                    children: [
                      Expanded(
                        child: NumberEditText(
                          hasFocus: true,
                          hint: 'suppliers_scan_input_operator'.tr,
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (state.peopleNumber.text.isEmpty) {
                            showSnackBar(title: 'shack_bar_warm'.tr, message: 'suppliers_scan_input_operator'.tr);
                          } else {
                           logic.goReport();
                           Get.back();
                          }
                        },
                        child:  Text('dialog_default_confirm'.tr),
                      ),
                      TextButton(
                        onPressed: () {
                          state.peopleName.value = '';
                          state.peopleNumber.clear();
                          Get.back();
                        },
                        child:  Text('dialog_default_cancel'.tr),
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

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 30),
          child: InkWell(
            child: Text('suppliers_scan_clean'.tr),
            onTap: () {
              askDialog(
                title: 'dialog_default_title_information'.tr,
                content: 'suppliers_scan_sure_clean_code'.tr,
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
                        hint: 'suppliers_scan_enter_register'.tr,
                        controller: tecCode,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SwitchButton(
                        onChanged: (s) => state.red.value = s,
                        name: 'suppliers_scan_red'.tr,
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
                        hint: 'suppliers_scan_is_scan'.tr,
                        text: state.barCodeList.length.toString(),
                      ),
                      textSpan(
                        hint: 'suppliers_scan_tray_number'.tr,
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
                    text: 'suppliers_scan_manually_add'.tr,
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
                    text: 'suppliers_scan_submit'.tr,
                    click: () {
                      if (logic.haveCodeData()) {
                        showCustomPickerDialog(context);
                      } else {
                        showSnackBar(
                            title: 'shack_bar_warm'.tr,
                            message: 'suppliers_scan_no_barcode'.tr);
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
    logic.getBarCodeStatusByDepartmentID(refresh: () {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    });
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) {
        logic.scanCode(code);
      }
    });
    super.initState();
  }
}
