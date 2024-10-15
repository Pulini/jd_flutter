import 'package:get/get.dart';

import '../../../route.dart';
import '../../../utils/web_api.dart';
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

  get error => null;

  queryOrder() {
    state.pageIndex.value = 0;
    state.querySmartDeliveryOrder(
      showLoading: true,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: () => Get.back(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  refreshOrder({required void Function() refresh}) {
    state.pageIndex.value = 0;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: refresh,
      error: (msg) => errorDialog(content: msg, back: refresh),
    );
  }

  loadMoreOrder({required Function() refresh}) {
    state.pageIndex.value++;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: refresh,
      error: (msg) {
        state.pageIndex.value--;
        errorDialog(content: msg, back: refresh);
      },
    );
  }

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
}
