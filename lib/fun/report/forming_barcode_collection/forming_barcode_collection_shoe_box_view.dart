import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, InkWell;
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_barcode_by_mono_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'forming_barcode_collection_logic.dart';

class FormingBarcodeCollectionShoeBoxPage extends StatefulWidget {
  const FormingBarcodeCollectionShoeBoxPage({super.key});

  @override
  State<FormingBarcodeCollectionShoeBoxPage> createState() =>
      _FormingBarcodeCollectionShoeBoxPageState();
}

class _FormingBarcodeCollectionShoeBoxPageState
    extends State<FormingBarcodeCollectionShoeBoxPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;

  _item(FormingBarcodeByMonoInfo data,int position) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: data.isSelect.value
              ? Border.all(color: Colors.red, width: 1)
              : Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: _text(
                  //尺码
                    mes: data.size?? '',
                    backColor: Colors.white,
                    head: false,
                    paddingNumber: 5)),
            Expanded(
                flex: 2,
                child: InkWell(
                  child:  _text(
                    //鞋盒条码信息
                      mes: data.barCode?? '',
                      backColor: Colors.white,
                      head: false,
                      paddingNumber: 5),
                  onTap: () {
                    reasonInputPopup(
                      title: [
                        Center(
                          child: Text(
                            'forming_code_collection_shoe_barcode'.tr,
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        )
                      ],
                      hintText: 'forming_code_collection_input_shoe_barcode'.tr,
                      isCanCancel: true,
                      confirm: (s) {
                        Get.back();
                        logic.addCode(click:true, code: s,position:position);
                      },
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  _text({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
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

  _title() {
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
                  child: _text(
                      //尺码
                      mes: 'forming_code_collection_shoe_size'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //鞋盒条码信息
                      mes: 'forming_code_collection_shoe_barcode'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'forming_code_collection_shoe_box'.tr,
        body: Column(
          children: [
            EditText(
              hint: 'forming_code_collection_enter_or_scan'.tr,
              controller: logic.shoeController,
              onChanged: (v) {
                state.shoeInstruction = v;
              },
            ),
            Row(
              children: [
                Expanded(
                    child: CombinationButton(
                  //查询
                  text: 'forming_code_collection_search_button'.tr,
                  click: () {
                    if (logic.shoeController.text.isNotEmpty) {
                      logic.getScMoSizeBarCodeByMONo(
                          shoeBill: logic.shoeController.text);
                    }
                  },
                  combination: Combination.left,
                )),
                Expanded(
                    child: CombinationButton(
                  //提交
                  text: 'forming_code_collection_submit_button'.tr,
                  click: () {
                    logic.shoeSubmit(success: (mes) {
                      successDialog(
                          content: mes,
                          back: () {
                            Get.back(result: logic.shoeController.text);
                          });
                    });
                  },
                  combination: Combination.middle,
                )),
                Expanded(
                    child: Obx(()=>CombinationButton(
                      //补零或清零
                      text: state.btnName.value,
                      click: () {
                          logic.addZero();
                      },
                      combination: Combination.middle,
                    ))),
                Expanded(
                    child: CombinationButton(
                  //清空条码
                  text: 'forming_code_collection_clear_button'.tr,
                  click: () {
                    logic.clearCode();
                  },
                  combination: Combination.right,
                )),
              ],
            ),
            _title(),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.barCodeByMonoData.length,
                  itemBuilder: (context, index) =>
                      _item(state.barCodeByMonoData[index],index),
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    pdaScanner(scan: (scanCode) {
      if (scanCode.length < 50) {
        if (state.shoeInstruction.isNullOrEmpty() || state.barCodeByMonoData.isNullOrEmpty()) {
          logic.shoeController.text = scanCode;
          logic.getScMoSizeBarCodeByMONo(shoeBill: scanCode);
        } else {
          if(logic.haveCode(scanCode)){  //不存在该条码可以继续
              logic.addCode( code: scanCode, click: false, position: -1,);
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    logic.quitShoe();
    super.dispose();
  }
}
