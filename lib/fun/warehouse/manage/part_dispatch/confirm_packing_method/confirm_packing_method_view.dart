import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/view_photo.dart';

import 'confirm_packing_method_logic.dart';
import 'confirm_packing_method_state.dart';

class ConfirmPackingMethodPage extends StatefulWidget {
  const ConfirmPackingMethodPage({super.key});

  @override
  State<ConfirmPackingMethodPage> createState() =>
      _ConfirmPackingMethodPageState();
}

class _ConfirmPackingMethodPageState extends State<ConfirmPackingMethodPage> {
  final ConfirmPackingMethodLogic logic = Get.put(ConfirmPackingMethodLogic());
  final ConfirmPackingMethodState state =
      Get.find<ConfirmPackingMethodLogic>().state;
  var refreshController = EasyRefreshController(controlFinishRefresh: true);

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.queryDispatchOrderInfo(barCode: code));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null) {
        logic.getOrderInfoFromArguments();
      }
      // logic.queryDispatchOrderInfo(barCode: 'GXPG250102613/1');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          margin: const EdgeInsets.all(5),
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.blue, width: 2),
            color: Colors.white,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => scannerDialog(
                    detect: (code) =>
                        logic.queryDispatchOrderInfo(barCode: code)),
                child: Container(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  height: 40,
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    ),
                    color: Colors.green,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                ),
              ),
              Obx(() => Container(
                    height: 40,
                    margin: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.blue,
                        ),
                        color: Colors.blue.shade100),
                    alignment: Alignment.center,
                    child: Text(
                      state.packingMethodName.value.isEmpty
                          ? 'part_dispatch_confirm_packing_method_select_packing_method'
                              .tr
                          : 'part_dispatch_confirm_packing_method_tips'.trArgs([
                              state.packingMethodName.value,
                              state.packingMethodCapacityQty.value
                                  .toShowString()
                            ]),
                    ),
                  )),
              CombinationButton(
                text: 'part_dispatch_confirm_packing_method_modify_packing_method'.tr,
                combination: Combination.right,
                click: () => selectPackProfileDialog(
                  orderPackProfileID: state.packingMethodID.value,
                  capacityQty: state.packingMethodCapacityQty.value,
                  packProfileList: state.packingMethodList
                      .map((v) => [v.itemID, v.name, v.boxCapacity])
                      .toList(),
                  callback: (id, capacityQty) => logic.modifyOrderPackProfile(
                    packProfileID: id,
                    capacityQty: capacityQty,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: EasyRefresh(
                controller: refreshController,
                header: const MaterialHeader(),
                onRefresh: () {
                  if (state.barCode.isNotEmpty) {
                    logic.refreshPartInfo(
                        () => refreshController.finishRefresh());
                  } else {
                    refreshController.finishRefresh();
                  }
                },
                child: Obx(() => GridView.builder(
                      itemCount: state.partList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 7 / 5,
                      ),
                      itemBuilder: (c, i) => _ConfirmPackingMethodPartGridItem(
                        data: state.partList[i],
                      ),
                    ))),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ConfirmPackingMethodLogic>();
    super.dispose();
  }
}

class _ConfirmPackingMethodPartGridItem extends StatelessWidget {
  final PartDispatchMaterialList data;

  const _ConfirmPackingMethodPartGridItem({required this.data});

  @override
  Widget build(BuildContext context) {
    var errorImage = Image.asset(
      'assets/images/ic_logo.png',
      color: Colors.blue,
    );
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 2 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: data.pictureUrl.isNullOrEmpty()
                  ? errorImage
                  : GestureDetector(
                      onTap: () {
                        if (!data.pictureUrl.isNullOrEmpty()) {
                          Get.to(
                              () => ViewNetPhoto(photos: [data.pictureUrl!]));
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: data.pictureUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, st) => errorImage,
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.materialName ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                data.qty.toShowString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            ],
          ),
        ],
      ),
    );
  }
}
