import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bean/home_button.dart';
import '../http/response/home_function_info.dart';
import '../route.dart';

class HomeState {
  String search = '';
  var navigationBarIndex = 0;
  RxList<ButtonItem> buttons = <ButtonItem>[].obs;
  var navigationBar = <BottomNavigationBarItem>[];
  var selectedItemColor = const Color(0xffffffff);

  void refreshFunctions(List<HomeFunctions> list) {
    functions.clear();
    navigationBarIndex = 0;
    var nBar = <BottomNavigationBarItem>[];

    for (var navigation in list) {
      nBar.add(BottomNavigationBarItem(
        icon: Image.network(
          navigation.icon ?? '',
          width: 30,
          height: 30,
          color: Color(navigation.fontColor ?? 0xffffffff),
          errorBuilder: (ctx, err, stackTrace) => Image.asset(
            'lib/res/images/ic_logo.png',
            height: 30,
            width: 30,
            color: Color(navigation.fontColor ?? 0xffffffff),
          ),
        ),
        label: navigation.className ?? 'Fun',
        backgroundColor: Color(navigation.backGroundColor!),
      ));

      var list = <ButtonItem>[];
      if (navigation.subFunctions != null) {
        for (var fun in navigation.subFunctions!) {
          if (fun.functionGroup != null && fun.functionGroup!.length > 1) {
            var subList = <HomeButton>[];
            for (var sub in fun.functionGroup!) {

              subList.add(HomeButton(
                name: sub.name ?? '',
                description: sub.description ?? '',
                classify: navigation.className ?? '',
                icon: sub.icon ?? '',
                id: sub.id ?? 0,
                // version: sub.version ?? 0,
                version: 99,
                route: sub.routeSrc ?? '',
                // hasPermission: sub.hasPermission ?? false,
                hasPermission: true,
              ));
            }
            list.add(HomeButtonGroup(
                name: fun.name ?? '',
                description: fun.description ?? '',
                classify: navigation.className ?? '',
                icon: fun.icon ?? '',
                functionGroup: subList));
          } else {
            list.add(HomeButton(
              name: fun.functionGroup![0].name ?? '',
              description: fun.functionGroup![0].description ?? '',
              classify: navigation.className ?? '',
              icon: fun.functionGroup![0].icon ?? '',
              id: fun.functionGroup![0].id ?? 0,
              // version: fun.functionGroup![0].version ?? 0,
              version: 99,
              route: fun.functionGroup![0].routeSrc ?? '',
              // hasPermission: fun.functionGroup![0].hasPermission ?? false,
              hasPermission: true,
            ));
          }
        }
      }
      functions.addAll(list);
    }

    navigationBar = nBar;
    if (nBar.isNotEmpty) {
      selectedItemColor = Color(list[0].fontColor ?? 0xffffffff);
    }
    refreshButton();
  }


  refreshButton() {
    buttons.clear();
    if (search.isEmpty) {
      buttons.addAll(
        functions.where((element) =>
            element.classify == navigationBar[navigationBarIndex].label),
      );
    } else {
      var list = <ButtonItem>[];
      for (var fun in functions) {
        if (fun is HomeButtonGroup) {
          list.addAll(fun.functionGroup);
        } else {
          list.add(fun);
        }
      }
      buttons.addAll(
        list.where((element) =>
            element.name.toUpperCase().contains(search.toUpperCase()) ||
            element.description.toUpperCase().contains(search.toUpperCase())),
      );
    }
  }
}
