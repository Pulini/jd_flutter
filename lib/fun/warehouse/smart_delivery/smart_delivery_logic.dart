import 'package:get/get.dart';

import '../../../route.dart';
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
    PickerType.sapGroup,
    saveKey: '${RouteConfig.smartDeliveryPage.name}${PickerType.sapGroup}',
  );

  queryOrder(){

  }

  refreshOrder({required void Function() refresh}) {

  }

  loadMoreOrder({required Function() refresh}) {

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
