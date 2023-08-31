import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/http/web_api.dart';

import '../bean/home_button.dart';
import '../http/response/version_info.dart';
import '../widget/dialogs.dart';

class HomeState {
  String search = '';
  var navigationBarIndex = 0.obs;
  RxList<ButtonItem> buttons = <ButtonItem>[].obs;

  refreshButton() {
    buttons.clear();
    buttons.addAll(
      appButtonList.where(
        (element) {
          if (search.isEmpty) {
            return element.classify == navigationBarIndex.value;
          } else {
            if (element is HomeButtonGroup) {
              return element.functionGroup.any((e2) {
                return e2.name.toUpperCase().contains(search.toUpperCase()) ||
                    e2.description.toUpperCase().contains(search.toUpperCase());
              });
            } else {
              return element.name
                      .toUpperCase()
                      .contains(search.toUpperCase()) ||
                  element.description
                      .toUpperCase()
                      .contains(search.toUpperCase());
            }
          }
        },
      ),
    );
  }

  getVersionList() {
    httpGet(method: webApiGetVersionList).then((version) {
      if (version.resultCode == resultSuccess) {
        List<FunctionVersion> list = [];
        for (var item in jsonDecode(version.data)) {
          list.add(FunctionVersion.fromJson(item));
        }
        var noJid=<HomeButton>[];
        var noDescription=<HomeButton>[];
        for (var bt in appButtonList) {
          if (bt is HomeButton) {
            if(bt.jid.isEmpty)noJid.add(bt);
            if(bt.description.isEmpty)noDescription.add(bt);
            var v = list.singleWhere((version) => version.id == bt.id);
            bt.hasUpdate = v.version! > bt.version;
          }
          if (bt is HomeButtonGroup) {
            for (var gbt in bt.functionGroup) {
              if(gbt.jid.isEmpty)noJid.add(gbt);
              if(gbt.description.isEmpty)noDescription.add(gbt);
              var v = list.singleWhere((version) => version.id == gbt.id);
              gbt.hasUpdate = v.version! > gbt.version;
            }
          }
        }
        var jidText='无权限码功能:${noJid.length}\n';
        var descriptionText='无描述功能:${noDescription.length}\n';
        noJid.map((e) =>e.name).forEach((element) {
          jidText+='功能名称：$element\n';
        });
        noDescription.map((e) =>e.name).forEach((element) {
          descriptionText+='功能名称：$element\n';
        });
        logger.f(jidText);
        logger.f(descriptionText);
        refreshButton();
      } else {
        errorDialog(content: version.message);
      }
    });
  }

  HomeState() {

    buttons.addAll(productionButton);
    refreshButtonPermission();
    getVersionList();
  }

  refreshButtonPermission() {
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
  }

  hasPermission(String jid) {
    return userController.user.value?.jurisdictionList
            ?.any((v) => jid == v.jid) ??
        false;
  }
}
