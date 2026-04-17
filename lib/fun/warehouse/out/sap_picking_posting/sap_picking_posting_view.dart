import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_posting_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_picking_posting/sap_picking_posting_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_picking_posting_logic.dart';
import 'sap_picking_posting_state.dart';

class SapPickingPostingPage extends StatefulWidget {
  const SapPickingPostingPage({super.key});

  @override
  State<SapPickingPostingPage> createState() => _SapPickingPostingPageState();
}

class _SapPickingPostingPageState extends State<SapPickingPostingPage> {
  final SapPickingPostingLogic logic = Get.put(SapPickingPostingLogic());
  final SapPickingPostingState state = Get.find<SapPickingPostingLogic>().state;
  var tecSemiFinishedProduct = TextEditingController();
  var tecFinishedProduct = TextEditingController();

  Widget _itemSemiFinishedProduct(SapPickingPostingGroup data) => Container(
        padding: EdgeInsets.only(left: 5),
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      data.material(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      minFontSize: 8,
                      maxFontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => askDialog(
                      content: '确定要删除该物料吗？',
                      confirm: () => logic.deleteSemiFinishedProductItem(data),
                    ),
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: textSpan(
                      hint: '累积数：',
                      hintColor: Colors.grey.shade700,
                      text: data.cumulativeQty().toShowString(),
                      isBold: false,
                    ),
                  ),
                  Expanded(
                    child: data.dataList.first.label.isNullOrEmpty()
                        ? Text(
                            '手动添加物料',
                            style: TextStyle(color: Colors.green.shade700),
                          )
                        : textSpan(
                            hint: '扫码次数：',
                            hintColor: Colors.grey.shade700,
                            text: data.scanCount().toString(),
                            isBold: false,
                          ),
                  ),
                  IconButton(
                    onPressed: () => semiFinishedProductDetailsDialog(data),
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const Divider(
              indent: 5,
              endIndent: 10,
              height: 2,
            ),
          ],
        ),
      );

  Widget productPageTitle({
    required String title,
    Color? bkgColor = Colors.indigoAccent,
  }) =>
      Container(
        height: 40,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
          ),
          color: bkgColor,
        ),
        child: Center(
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            minFontSize: 14,
            maxFontSize: 24,
          ),
        ),
      );

  late var semiFinishedProductPageInput = Container(
    width: double.infinity,
    color: Colors.white,
    height: 45,
    padding: EdgeInsets.only(left: 5, top: 5, right: 5),
    child: TextField(
      controller: tecSemiFinishedProduct,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 15,
          right: 10,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        hintText: '请扫描或输入半成品条码',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: IconButton(
          onPressed: () => tecSemiFinishedProduct.clear(),
          icon: const Icon(
            Icons.replay_circle_filled,
            color: Colors.red,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => logic.getMaterialDetail(
            code: tecSemiFinishedProduct.text,
            semiFinishedProduct: () {
              tecSemiFinishedProduct.clear();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          icon: Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );

  late var finishedProductPageInput = Container(
    width: double.infinity,
    color: Colors.white,
    height: 45,
    padding: EdgeInsets.only(left: 5, top: 5, right: 5),
    child: TextField(
      controller: tecFinishedProduct,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 15,
          right: 10,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        hintText: '请扫描或输入成品条码',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: IconButton(
          onPressed: () => tecFinishedProduct.clear(),
          icon: const Icon(
            Icons.replay_circle_filled,
            color: Colors.red,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => logic.getMaterialDetail(
            code: tecFinishedProduct.text,
            finishedProduct: () {
              tecFinishedProduct.clear();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          icon: Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pdaScanner(scan: (code) {
        logic.getMaterialDetail(code: code);
        FocusManager.instance.primaryFocus?.unfocus();
      });
      logic.getNewOrderNumber();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          text: '暂存记录',
          click: () => pickingCacheDialog(
              refresh: (orderNumber, labels) =>
                  logic.refreshLabels(orderNumber, labels)),
        ),
      ],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Obx(() => textSpan(hint: '拣配单号:', text: state.order.value)),
          ),
          Expanded(
            child: Obx(() => ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    productPageTitle(title: '拣配半成品条码明细', bkgColor: Colors.blue),
                    semiFinishedProductPageInput,
                    for (var item in state.semiFinishedProductList)
                      _itemSemiFinishedProduct(item),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: CombinationButton(
                              text: '添加物料',
                              combination: Combination.left,
                              click: () => addSemiFinishedProductMaterialDialog(
                                  state.semiFinishedProductList),
                            ),
                          ),
                          Expanded(
                            child: CombinationButton(
                              text: '清空列表',
                              combination: Combination.right,
                              isEnabled:
                                  state.semiFinishedProductList.isNotEmpty,
                              backgroundColor: Colors.orange,
                              click: () => askDialog(
                                title: '半成品拣配',
                                content: '确定要清空所有已扫入的物料吗？',
                                confirm: () => logic.clearSemiFinishedProduct(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    productPageTitle(
                      title: '拣配成品条码明，只允许编码/订单相同',
                      bkgColor: Colors.green,
                    ),
                    finishedProductPageInput,
                    state.finishedProductList.isNotEmpty
                        ? Container(
                            padding:
                                EdgeInsets.only(left: 5, right: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  '(${state.finishedProductList.first.materialCode})${state.finishedProductList.first.materialName}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  minFontSize: 8,
                                  maxFontSize: 16,
                                ),
                                SizedBox(
                                  height: 35,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: textSpan(
                                          hint: '订单号：',
                                          hintColor: Colors.grey.shade700,
                                          text: state.finishedProductList.first
                                                  .salesOrder ??
                                              '',
                                          isBold: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: textSpan(
                                          hint: '数量：',
                                          hintColor: Colors.grey.shade700,
                                          text: state.finishedProductList
                                              .map((v) => v.quantity ?? 0)
                                              .reduce((a, b) => a.add(b))
                                              .toShowString(),
                                          isBold: false,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => askDialog(
                                          content: '确定要删除该物料吗？',
                                          confirm: () =>
                                              logic.clearFinishedProduct(),
                                        ),
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              color: Colors.white,
                            ),
                          ),
                  ],
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: '暂存',
                  click: () => askDialog(
                    content: '确定要暂存本次拣配吗？',
                    confirm: () => logic.submitPickingLabel(false),
                  ),
                  backgroundColor: Colors.orange,
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '提交',
                  click: () => askDialog(
                    content: '确定要提交本次拣配吗？',
                    confirm: () => logic.submitPickingLabel(true),
                  ),
                  backgroundColor: Colors.green,
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPickingPostingLogic>();
    super.dispose();
  }
}
