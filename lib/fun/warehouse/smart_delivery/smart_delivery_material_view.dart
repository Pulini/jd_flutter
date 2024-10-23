import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/smart_delivery/smart_delivery_create_order_view.dart';
import 'package:jd_flutter/fun/warehouse/smart_delivery/smart_delivery_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

import '../../../bean/http/response/smart_delivery_info.dart';

class SmartDeliveryMaterialListPage extends StatefulWidget {
  const SmartDeliveryMaterialListPage({super.key});

  @override
  State<SmartDeliveryMaterialListPage> createState() =>
      _SmartDeliveryMaterialListPageState();
}

class _SmartDeliveryMaterialListPageState
    extends State<SmartDeliveryMaterialListPage> {
  final logic = Get.find<SmartDeliveryLogic>();
  final state = Get.find<SmartDeliveryLogic>().state;
  final typeBody = Get.arguments['typeBody'];

  modifyShoeTreeDialog(SmartDeliveryShorTreeInfo sti) {
    Get.dialog(PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('楦头库存维护'),
        content: SizedBox(
            width: 460,
            height: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(hint: '型体：', text: typeBody),
                textSpan(hint: '楦头号：', text: sti.shoeTreeNo ?? ''),
                Expanded(
                  child: GridView.builder(
                    itemCount: sti.sizeList?.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 1,
                    ),
                    itemBuilder: (context, index) {
                      var controller = TextEditingController(
                        text: sti.sizeList?[index].qty.toString(),
                      );
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: [
                              textSpan(
                                hint: '尺码：',
                                text: sti.sizeList?[index].size ?? '',
                              ),
                              const SizedBox(width: 30),
                              Text(
                                '库存：',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (c) {
                                    sti.sizeList?[index].qty = c.toIntTry();
                                    controller.text = c.toIntTry().toString();
                                    controller.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                        offset: controller.text.length,
                                      ),
                                    );
                                  },
                                  controller: controller,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () => logic.saveShoeTree(
              sti,
              typeBody,
              () => Get.back(),
            ),
            child: Text('保存'),
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
    ));
  }

  _item(SmartDeliveryMaterialInfo data) {
    return GestureDetector(
      onTap: () =>logic.getDeliveryDetail(data,()=> Get.to(() => const CreateDeliveryOrderPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: '部位：',
                  text: data.partName ?? '',
                  fontSize: 16,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  flex: 1,
                  hint: '物料代码：',
                  text: data.materialNumber ?? '',
                  fontSize: 16,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  flex: 2,
                  hint: '物料名称：',
                  text: data.materialName ?? '',
                  fontSize: 16,
                  textColor: Colors.blue.shade900,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '发料情况：',
                  style: TextStyle(color: Colors.black45),
                ),
                Expanded(
                  child: progressIndicator(
                    max: data.requireQty ?? 0,
                    value: data.sendQty ?? 0,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '材料清单',
      actions: [
        CombinationButton(
          text: '楦头库存维护',
          click: () => logic.getShoeTreeList(
            typeBody,
            (sti) => modifyShoeTreeDialog(sti),
          ),
        )
      ],
      body: Column(
        children: [
          EditText(
            hint: '输入物料代码查询',
            onChanged: (v) => state.searchMaterial(v),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.materialShowList.length,
                  itemBuilder: (context, index) =>
                      _item(state.materialShowList[index]),
                )),
          ),
        ],
      ),
    );
  }
}
