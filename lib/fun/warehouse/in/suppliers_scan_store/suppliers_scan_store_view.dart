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
                    const Text(
                      '入库条件',
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => {
                            if (state.peopleNumber.text.isEmpty)
                              {showSnackBar(title: '警告', message: '请输入操作人工号')}
                            else
                              {Navigator.of(context).pop(), logic.goReport()}
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
            ),);
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
              Obx(()=>Row(
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
                        logic.scanCode(state.handCode);
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
                          showCustomPickerDialog(context);
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
    logic.getBarCodeStatusByDepartmentID(refresh: (){});
    pdaScanner(scan: (code) {
      logic.scanCode(code);
    });
    super.initState();
  }
}
