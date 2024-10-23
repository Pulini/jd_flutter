import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/smart_delivery/smart_delivery_material_view.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'smart_delivery_state.dart';

class SmartDeliveryLogic extends GetxController {
  final SmartDeliveryState state = SmartDeliveryState();

  ///日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.smartDeliveryPage.name}StartDate',
  );

  ///日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.smartDeliveryPage.name}EndDate',
  );

  ///组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.mesGroup,
    saveKey: '${RouteConfig.smartDeliveryPage.name}${PickerType.mesGroup}',
  );

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  refreshOrder({required void Function() refresh}) {
    state.pageIndex.value = 1;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: (length) => refresh.call(),
      error: (msg) => errorDialog(content: msg, back: refresh),
    );
  }

  loadMoreOrder({
    required Function(bool) success,
    required Function() error,
  }) {
    state.pageIndex.value++;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: (length) => success.call(state.maxPageSize > length),
      error: (msg) {
        state.pageIndex.value--;
        errorDialog(content: msg, back: error);
      },
    );
  }

  getOrderMaterialList(int workCardInterID, String typeBody) {
    state.getOrderMaterialList(
      workCardInterID: workCardInterID,
      success: () => Get.to(
        () => const SmartDeliveryMaterialListPage(),
        arguments: {'typeBody': typeBody},
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getShoeTreeList(
      String typeBody, Function(SmartDeliveryShorTreeInfo) setShoeTree) {
    state.getShoeTreeList(
      typeBody: typeBody,
      success: setShoeTree,
      error: (msg) => errorDialog(content: msg),
    );
  }

  saveShoeTree(
    SmartDeliveryShorTreeInfo sti,
    String typeBody,
    Function() success,
  ) {
    state.saveShoeTree(
      sti: sti,
      typeBody: typeBody,
      success: (msg) => successDialog(content: msg, back: success),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getDeliveryDetail(SmartDeliveryMaterialInfo data, Function() success) {
    state.getDeliveryDetail(
      sdmi: data,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  setDeliveryLines(int reserve) {
    state.deliveryDetailList.value = <WorkData>[
      WorkData(round: '尺码', sendType: -1, taskID: '', sendSizeList: <SizeInfo>[
        for (var data in state.deliveryDetail!.partsSizeList ?? [])
          SizeInfo(size: data.size, qty: 0)
      ]),
      WorkData(
          round: '楦头库存',
          sendType: -1,
          taskID: '',
          sendSizeList: <SizeInfo>[
            for (var data in state.deliveryDetail!.partsSizeList ?? [])
              SizeInfo(size: data.size, qty: data.qty)
          ]),
      WorkData(
          round: '预排楦头',
          sendType: -1,
          taskID: '',
          sendSizeList: <SizeInfo>[
            for (var data in state.deliveryDetail!.partsSizeList ?? [])
              SizeInfo(size: data.size, qty: data.qty - reserve)
          ]),
      // for (var json in deliveryDetail!.workData) WorkData.fromJson(json)
    ];
  }
}
