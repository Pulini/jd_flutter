import 'package:get/get.dart';
import 'package:jd_flutter/http/web_api.dart';

import '../bean/home_button.dart';

class HomeState {
  String search = "";
  var navigationBarIndex = 0.obs;
  var buttons = <ButtonItem>[].obs;

  var buttonList = <ButtonItem>[
    ...productionButton,
    ...warehouseButton,
    ...manageButton
  ];

  HomeState() {
    for (var bt in buttonList) {
      if (bt is HomeButton) {
        bt.lock = hasPermission(bt.jid);
      }
      if (bt is HomeButtonGroup) {
        for (var gbt in bt.functionGroup) {
          gbt.lock = hasPermission(gbt.jid);
        }
      }
    }
    buttons.addAll(productionButton);
  }

  hasPermission(String jid) {
    return userController.user.value?.jurisdictionList
            ?.any((v) => jid == v.jid) ??
        false;
  }
}
