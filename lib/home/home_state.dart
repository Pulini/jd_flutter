import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/http/web_api.dart';

import '../bean/home_button.dart';
import '../http/response/version_info.dart';
import '../widget/dialogs.dart';

class HomeState {
  String search = '';
  var navigationBarIndex = 0.obs;
  var buttons = <ButtonItem>[].obs;

  getVersionList() {
    httpGet(method: webApiGetVersionList).then((version) {
      if (version.resultCode == resultSuccess) {
        List<FunctionVersion> list = [];
        for (var item in jsonDecode(version.data)) {
          list.add(FunctionVersion.fromJson(item));
        }
        for (var bt in appButtonList) {
          if (bt is HomeButton) {
            var v = list.singleWhere((version) => version.id == bt.id);
            bt.hasUpdate = v.version! > bt.version;
          }
          if (bt is HomeButtonGroup) {
            for (var gbt in bt.functionGroup) {
              var v = list.singleWhere((version) => version.id == gbt.id);
              gbt.hasUpdate = v.version! > gbt.version;
            }
          }
        }
        buttons.refresh();
      } else {
        errorDialog(content: version.message);
      }
    });
  }

  HomeState() {
    buttons.addAll(appButtonList);
    refreshButtonPermission();
    getVersionList();
  }

  refreshButtonPermission(){
    for (var bt in appButtonList) {
      if (bt is HomeButton) {
        bt.lock = hasPermission(bt.jid);
      }
      if (bt is HomeButtonGroup) {
        for (var gbt in bt.functionGroup) {
          gbt.lock = hasPermission(gbt.jid);
        }
      }
    }
    buttons.refresh();
  }
  hasPermission(String jid) {
    return userController.user.value?.jurisdictionList
            ?.any((v) => jid == v.jid) ??
        false;
  }


}
