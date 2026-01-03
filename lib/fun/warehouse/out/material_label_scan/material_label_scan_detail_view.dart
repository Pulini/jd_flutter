import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'material_label_scan_state.dart';

class MaterialLabelScanDetailPage extends StatefulWidget {
  const MaterialLabelScanDetailPage({super.key});

  @override
  State<MaterialLabelScanDetailPage> createState() =>
      _MaterialLabelScanDetailPageState();
}

class _MaterialLabelScanDetailPageState
    extends State<MaterialLabelScanDetailPage> {
  final MaterialLabelScanLogic logic = Get.find<MaterialLabelScanLogic>();
  final MaterialLabelScanState state = Get.find<MaterialLabelScanLogic>().state;

  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);
  var blackText = Colors.black;
  var greenText = Colors.green;
  var redText = Colors.red;
  var yellowText = Colors.yellow;

  void showPickerDialog(BuildContext context) {
    WorkerInfo? newWorker;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          child: Dialog(
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 180,
              width: 200,
              child: Column(
                children: [
                  Text(
                    'dialog_default_title_information'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: NumberEditText(
                          hasFocus: true,
                          hint: 'material_label_scan_detail_input_picker_number'.tr,
                          controller: state.peopleNumber,
                          onChanged: (s) {
                            if (s.length >= 6) {
                              getWorkerInfo(
                                number: s,
                                workers: (list) {
                                  newWorker = list[0];
                                  state.peopleName.value = list[0].empName ?? '';
                                },
                                error: (msg) => errorDialog(content: msg),
                              );
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
                          if (newWorker != null) {
                            Navigator.of(context).pop();
                            logic.submit(newWorker!);
                          } else {
                            showSnackBar(
                                title: 'shack_bar_warm'.tr,
                                message: 'material_label_scan_detail_input_picker_number'.tr);
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

  Container _titleText({
    required String mes,
    required Color backColor,
    required Color textColor,
    required double paddingNumber,
  }) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            maxLines: 1,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Column _title() {
    const borders = BorderSide(color: Colors.grey, width: 1);
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            border: const Border(top: borders, left: borders, right: borders),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //尺码
                      mes: 'material_label_scan_detail_size'.tr,
                      backColor: Colors.lightBlueAccent,
                      paddingNumber: 5,
                      textColor: blackText)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //订单数
                      mes: 'material_label_scan_detail_order_qty'.tr,
                      backColor: Colors.lightBlueAccent,
                      textColor: blackText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //已领
                      mes: 'material_label_scan_detail_claimed'.tr,
                      backColor: Colors.lightBlueAccent,
                      textColor: greenText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //未领
                      mes: 'material_label_scan_detail_not_claimed'.tr,
                      backColor: Colors.lightBlueAccent,
                      textColor: redText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //本次领料
                      mes: 'material_label_scan_detail_this_collar'.tr,
                      backColor: Colors.lightBlueAccent,
                      textColor: yellowText,
                      paddingNumber: 5)),
            ],
          ),
        )
      ],
    );
  }

  Row _text(String hint, String? text1) {
    return Row(
      children: [
        Container(
          width: 60,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
          child: InkWell(
            child: Text(text1 ?? '', style: textStyle),
            onTap: () {
              if (text1!.isNotEmpty) {
                showSnackBar(message: text1);
              }
            },
          ),
        ),
      ],
    );
  }

  Column _item(List<Items> data) {
    return Column(
      children: [
        _title(),
        // 表格内容
        ...data.map((item) => Row(
              children: [
                Expanded(
                    flex: 1,
                    child: _titleText(
                        mes: item.size ?? '',
                        backColor: Colors.white,
                        paddingNumber: 5,
                        textColor: blackText)),
                Expanded(
                    flex: 1,
                    child: _titleText(
                        mes: item.orderQty.toShowString(),
                        backColor: Colors.white,
                        textColor: blackText,
                        paddingNumber: 5)),
                Expanded(
                    flex: 1,
                    child: _titleText(
                        mes: item.qtyReceived.toShowString(),
                        backColor: Colors.white,
                        textColor: greenText,
                        paddingNumber: 5)),
                Expanded(
                    flex: 1,
                    child: _titleText(
                        mes: item.unclaimedQty.toShowString(),
                        backColor: Colors.white,
                        textColor: redText,
                        paddingNumber: 5)),
                Expanded(
                    flex: 1,
                    child: _titleText(
                        mes: item.thisTime.toShowString(),
                        backColor: Colors.white,
                        textColor: yellowText,
                        paddingNumber: 5)),
              ],
            )),

        // 合计行
        if (data.isNotEmpty)
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: _titleText(
                      mes: '合计',
                      backColor: Colors.white,
                      paddingNumber: 5,
                      textColor: blackText)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      mes: data
                          .map((v) => v.orderQty ?? 0.0)
                          .reduce((a, b) => a.add(b))
                          .toShowString(),
                      backColor: Colors.white,
                      textColor: blackText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      mes: data
                          .map((v) => v.qtyReceived ?? 0.0)
                          .reduce((a, b) => a.add(b))
                          .toShowString(),
                      backColor: Colors.white,
                      textColor: greenText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      mes: data
                          .map((v) => v.unclaimedQty ?? 0.0)
                          .reduce((a, b) => a.add(b))
                          .toShowString(),
                      backColor: Colors.white,
                      textColor: redText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      mes: data
                          .map((v) => v.thisTime ?? 0.0)
                          .reduce((a, b) => a.add(b))
                          .toShowString(),
                      backColor: Colors.white,
                      textColor: yellowText,
                      paddingNumber: 5)),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'material_label_scan_material_detail'.tr,
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const Scanner())?.then((v) {
                  if (v != null) {
                    logic.queryBarCodeDetail(barCode: '2049423001196.5/3001');
                  }
                });
              },
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Colors.grey,
              ))
        ],
        body: Column(
          children: [
            _text('material_label_scan_detail_order'.tr,
                state.dataDetail.head?[0].workCardNo ?? ''),
            _text('material_label_scan_detail_type_body'.tr,
                state.dataDetail.head?[0].productName ?? ''),
            _text(
                'material_label_scan_detail_material'.tr,
                (state.dataDetail.head?[0].materialNumber ?? '') +
                    (state.dataDetail.head?[0].materialName ?? '')),
            _text('material_label_scan_detail_command'.tr,
                state.dataDetail.head?[0].mtoNo ?? ''),
            _text(
                'material_label_scan_detail_quantity'.tr,
                (state.dataDetail.head?[0].scWorkCardQty.toShowString() ?? '') +
                    (state.dataDetail.head?[0].unitName ?? '')),
            // 在 build 方法中替换原有的 ListView.builder
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.dataDetailList.length,
                  itemBuilder: (context, index) {
                    var entry = state.dataDetailList.entries.elementAt(index);
                    var materialKey = entry.key;
                    var dataList = entry.value;

                    return Column(
                      children: [
                        // 材料标题
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '材料: <$materialKey> ${dataList.first.materialName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 表格内容
                        _item(dataList),
                      ],
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    //清空条码
                    text: 'material_label_scan_detail_clear_barcode'.tr,
                    click: () {
                      askDialog(
                          content:
                              'material_label_scan_detail_sure_clear_barcode'
                                  .tr,
                          confirm: () {
                            logic.clearBarCode();
                          });
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  //提交
                  child: CombinationButton(
                    text: 'material_label_scan_detail_submit'.tr,
                    click: () {
                      logic.checkSubmit(success: (){
                        showPickerDialog(context);
                      });
                    },
                    combination: Combination.right,
                  ),
                ),
              ],
            )
          ],
        ));
  }

// 修改 showSnackBar 方法的调用方式
  void scanBarCode() {
    pdaScanner(
      scan: (code) {
        if (state.canScan) {
          if (code.isNotEmpty) {
            logic.queryBarCodeDetail(barCode: code);
          }
        } else {
          // 使用更安全的方式显示提示信息
          if (Get.isRegistered<SnackbarController>()) {
            showSnackBar(message: 'material_label_scan_detail_quick'.tr);
            state.canScan = true;
          } else {
            // 备用方案：使用 ScaffoldMessenger
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('material_label_scan_detail_quick'.tr)),
            );
            state.canScan = true;
          }
        }
      },
    );
  }


  @override
  void initState() {
    state.canScan = true;
    scanBarCode();
    super.initState();
  }
}
