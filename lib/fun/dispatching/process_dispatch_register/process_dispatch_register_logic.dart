import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'process_dispatch_register_state.dart';

class ProcessDispatchRegisterLogic extends GetxController {
  final ProcessDispatchRegisterState state = ProcessDispatchRegisterState();

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


  queryOrder() {
    state.getProcessWorkCardByBarcode(
      barCode: state.order.value,
      success: () {  },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
