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
                  const Text(
                    '入库条件',
                    style: TextStyle(
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
                          hint: '请输入操作人工号',
                          controller: state.peopleNumber,
                          onClear: () => {
                            state.peopleName.value = '',
                          },
                          onChanged: (s) {
                            if (s.length >= 6) {
                              logic.checkOrderInfo(number: s);
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
                        onPressed: () => {
                          if (state.peopleNumber.text.isEmpty)
                            {
                              showSnackBar(title: '警告', message: '请输入操作人工号'),
                            }
                          else
                            {
                              Navigator.of(context).pop(),
                              logic.goReport(),
                            }
                        },
                        child: const Text('确定'),
                      ),
                      TextButton(
                        onPressed: () => {
                          state.peopleName.value = '',
                          state.peopleNumber.clear(),
                          Navigator.of(context).pop()
                        },
                        child: const Text('取消'),
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
        onLongPress: () => {
              logic.deleteCode(code),
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
                code.isUsed ? '未汇报' : '',
                style: TextStyle(
                    color: code.isUsed ? Colors.red.shade700 : Colors.black),
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
            child: const Text('清空'),
            onTap: () => {
              askDialog(
                title: '温馨提示',
                content: '确定要清空条码吗?',
                confirm: () {
                  logic.clearBarCodeList();
                },
              ),
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
                        hint: '手动录入登记',
                        onChanged: (s) => {
                          state.handCode = s,
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SwitchButton(
                        onChanged: (s) => state.red.value = s,
                        name: '红冲',
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
                        hint: '已扫描：',
                        text: state.barCodeList.length.toString(),
                      ),
                      textSpan(
                        hint: '托盘号：',
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
                    text: '手动添加',
                    click: () {
                      if (state.handCode.isNotEmpty) {
                        logic.scanCode(state.handCode);
                      }
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: '提交',
                    click: () {
                      if (logic.haveCodeData()) {
                        if (state.isCheck == true) {
                          //已验证过再次验证
                          askDialog(
                              content: '确定要再次验证吗？',
                              confirmText: '校验',
                              confirmColor: Colors.red,
                              confirm: () {
                                logic.checkCodeList(
                                  checkBack: (s) => errorDialog(content: s),
                                ); //再次验证条码
                              },
                              cancelText: '提交',
                              cancelColor: Colors.blue,
                              cancel: () {
                                showCustomPickerDialog(context);
                              });
                        } else {
                          logic.checkCodeList(
                            checkBack: (s) => errorDialog(content: s),
                          ); //没验证过，首次验证条码
                        }
                      } else {
                        showSnackBar(title: '警告', message: '没用可提交的条码');
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
}
