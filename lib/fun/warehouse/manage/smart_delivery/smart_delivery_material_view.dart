import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

import 'smart_delivery_create_order_view.dart';
import 'smart_delivery_dialog.dart';
import 'smart_delivery_logic.dart';


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
  final departmentID = Get.arguments['departmentID'];

  _item(SmartDeliveryMaterialInfo data) {
    return GestureDetector(
      onTap: () {
        logic.getDeliveryDetail(
          data,
          departmentID,
          () => Get.to(() => const CreateDeliveryOrderPage())?.then((v) {
            logic.callbackRefresh(data);
          }),
        );
      },
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var save = spGet('SmartDeliveryMaterialListSearch').toString();
      setState(() {
        if (save != 'null') {
          state.searchText = save;
          state.searchMaterial(state.searchText);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '材料清单',
      actions: [
        CombinationButton(
          text: '楦头库存维护',
          click: () => modifyShoeTreeDialog(typeBody,departmentID),
        )
      ],
      body: Column(
        children: [
          EditText(
            hint: '输入物料代码查询',
            controller: TextEditingController(text: state.searchText),
            onChanged: (v) {
              state.searchMaterial(v);
              spSave('SmartDeliveryMaterialListSearch', v);
            },
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