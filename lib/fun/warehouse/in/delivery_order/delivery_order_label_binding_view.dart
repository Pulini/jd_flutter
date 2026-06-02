import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'delivery_order_logic.dart';
import 'delivery_order_state.dart';

class DeliveryOrderLabelBindingPage extends StatefulWidget {
  const DeliveryOrderLabelBindingPage({super.key});

  @override
  State<DeliveryOrderLabelBindingPage> createState() =>
      _DeliveryOrderLabelBindingPageState();
}

class _DeliveryOrderLabelBindingPageState
    extends State<DeliveryOrderLabelBindingPage>
    with SingleTickerProviderStateMixin {
  final DeliveryOrderLogic logic = Get.find<DeliveryOrderLogic>();
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;
  late TabController tabController = TabController(length: 2, vsync: this);
  var pieceController = TextEditingController();

  @override
  void initState() {
    state.canAddPiece.value = false;
    state.palletNumber.value='';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getLabelBindingStaging();
    });
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) logic.scanLabel(code);
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    pieceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'delivery_order_label_check_title'.tr,
      popTitle: 'delivery_order_label_check_exit_tips'.tr,
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: 'delivery_order_label_check_clear_tips'.tr,
            confirm: () => state.scannedLabelList.clear(),
          ),
          child: Text('delivery_order_label_check_clear'.tr),
        )
      ],
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: 40,
            child: TextField(
              controller: pieceController,
              onChanged: (v) => state.canAddPiece.value = v.isNotEmpty,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 15,
                  right: 10,
                ),
                filled: true,
                fillColor: Colors.grey.shade300,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                labelText: 'delivery_order_label_check_piece_id'.tr,
                prefixIcon: IconButton(
                  onPressed: () {
                    pieceController.clear();
                    state.canAddPiece.value = false;
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  ),
                ),
                suffixIcon: Obx(() => CombinationButton(
                      isEnabled: state.canAddPiece.value,
                      text: 'delivery_order_label_check_add_piece'.tr,
                      click: () =>
                          logic.addPiece(pieceNo: pieceController.text),
                    )),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Row(
              children: [
                Obx(() => textSpan(
                      hint: 'delivery_order_label_check_scanned'.tr,
                      text: state.scannedLabelList.where((v)=>v.isChecked.value).length.toString(),
                    )),
                Expanded(
                  child: TabBar(
                    controller: tabController,
                    dividerColor: Colors.blueAccent,
                    indicatorColor: Colors.blueAccent,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.black54,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs:  [
                      Tab(text: 'delivery_order_label_check_tab_progress'.tr),
                      Tab(text: 'delivery_order_label_check_tab_pallet_detail'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => TabBarView(
                  controller: tabController,
                  children: [
                    _LabelScanningList(logic: logic),
                    _LabelPalletList(logic: logic),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => textSpan(
                      hint: 'delivery_order_label_check_this_pallet'.tr,
                      text: state.palletNumber.value,
                      textColor: Colors.green.shade700,
                    )),
                textSpan(
                  hint: 'delivery_order_label_check_order_no'.tr,
                  text: state.orderItemInfo[0].deliNo ?? '',
                  textColor: Colors.green.shade700,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.scannedLabelList.isNotEmpty,
                      text: 'delivery_order_label_check_temporary'.tr,
                      click: () => logic.stagingLabelBinding(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: logic.isCanSubmitBinding(),
                      text: 'delivery_order_label_check_submit'.tr,
                      click: () => logic.submitLabelBinding(),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _LabelScanningList extends StatelessWidget {
  final DeliveryOrderLogic logic;
  const _LabelScanningList({required this.logic});

  @override
  Widget build(BuildContext context) {
    var list = logic.getLabelList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (c, i) => _LabelMaterialItem(
        map: list[i],
        logic: logic,
        deletePiece: (data) => logic.deletePiece(pieceInfo: data),
      ),
    );
  }
}

class _LabelPalletList extends StatelessWidget {
  final DeliveryOrderLogic logic;
  const _LabelPalletList({required this.logic});

  @override
  Widget build(BuildContext context) {
    var list = logic.getPalletList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (c, i) => _LabelPalletItem(
        map: list[i],
        deletePiece: (data) => logic.deletePiece(pieceInfo: data),
      ),
    );
  }
}

class _LabelMaterialItem extends StatelessWidget {
  final Map<String, List<dynamic>> map;
  final DeliveryOrderLogic logic;
  final void Function(DeliveryOrderLabelInfo) deletePiece;

  const _LabelMaterialItem({
    required this.map,
    required this.logic,
    required this.deletePiece,
  });

  @override
  Widget build(BuildContext context) {
    var materialCode = map.keys.first;
    var list = map.values.first;
    return Obx(() => Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  textSpan(hint: 'delivery_order_label_check_material'.tr, text: materialCode),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomProgressIndicator(
                      max: logic.getMaterialsTotal(materialCode),
                      value: logic.getScanProgress(materialCode),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              for (var size in list)
                ..._LabelSizeItem(
                  size: size,
                  materialCode: materialCode,
                  logic: logic,
                  deletePiece: deletePiece,
                ).build(context),
            ],
          ),
        ));
  }
}

class _LabelSizeItem {
  final List<dynamic> size;
  final String materialCode;
  final DeliveryOrderLogic logic;
  final void Function(DeliveryOrderLabelInfo) deletePiece;

  _LabelSizeItem({
    required this.size,
    required this.materialCode,
    required this.logic,
    required this.deletePiece,
  });

  List<Widget> build(BuildContext context) {
    return [
      if ((size[0] as String).isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${size[0]}#',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                child: CustomProgressIndicator(
                  max: size[1],
                  color: Colors.blue.shade300,
                  value: logic.getSizeScanProgress(materialCode, size[0] ?? ''),
                ),
              )
            ],
          ),
        ),
      for (DeliveryOrderLabelInfo label in size[2])
        _LabelItem(data: label, deletePiece: deletePiece),
    ];
  }
}

class _LabelItem extends StatelessWidget {
  final DeliveryOrderLabelInfo data;
  final void Function(DeliveryOrderLabelInfo) deletePiece;

  const _LabelItem({required this.data, required this.deletePiece});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: data.isChecked.value
            ? Colors.green.shade200
            : Colors.grey.shade300,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${data.pieceNo}${data.size?.isNotEmpty == true ? '   ${data.size}#' : ''}',
              style: TextStyle(
                color: data.isChecked.value ? Colors.black87 : Colors.black38,
              ),
            ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: 'delivery_order_label_check_delete_tips'.tr,
              confirm: () => deletePiece(data),
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}

class _LabelPalletItem extends StatelessWidget {
  final Map<String, List<DeliveryOrderLabelInfo>> map;
  final void Function(DeliveryOrderLabelInfo) deletePiece;

  const _LabelPalletItem({
    required this.map,
    required this.deletePiece,
  });

  @override
  Widget build(BuildContext context) {
    var palletNo = map.keys.first;
    var labelList = map.values.first;
    return Obx(
      () => palletNo.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textSpan(hint: 'delivery_order_label_check_pallet'.tr, text: palletNo),
                      textSpan(
                        hint: 'delivery_order_label_check_piece'.tr,
                        hintColor: Colors.black45,
                        text: labelList.length.toString(),
                        textColor: Colors.black87,
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  for (var label in labelList)
                    _LabelItem(data: label, deletePiece: deletePiece),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  for (var label in labelList)
                    _LabelItem(data: label, deletePiece: deletePiece),
                ],
              ),
            ),
    );
  }
}
