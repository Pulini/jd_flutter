import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/home_function_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/utils.dart';

abstract class ButtonItem {
  late String name;
  late String description;
  late String icon;
  late String classify;

  ButtonItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.classify,
  });
}

class HomeButton extends ButtonItem {
  late int id;
  late int version;
  late String route;
  late bool hasPermission;

  late bool hasUpdate = true;

  HomeButton({
    required super.name,
    required super.description,
    required super.classify,
    required super.icon,
    required this.id,
    required this.version,
    required this.route,
    required this.hasPermission,
  }) {
    for (var r in RouteConfig.routeList) {
      if (r.name == route) {
        hasUpdate = version > r.version;
        break;
      }
    }
  }

  toFunction({required Function() checkUpData}) {
    functionTitle=name;
    Get.toNamed(route)?.then((_)=>checkUpData.call());
  }
}
var functionTitle='';

class HomeButtonGroup extends ButtonItem {
  List<HomeButton> functionGroup;

  HomeButtonGroup({
    required super.name,
    required super.description,
    required super.icon,
    required super.classify,
    required this.functionGroup,
  });
}

List<ButtonItem> formatButton(List<HomeFunctions> data) {
  var functions = <ButtonItem>[];
  for (var navigation in data) {
    var list = <ButtonItem>[];
    for (var fun in navigation.subFunctions ?? <SubFunctions>[]) {
      if (fun.functionGroup != null && fun.functionGroup!.length > 1) {
        var subList = <HomeButton>[
          for (var sub in fun.functionGroup!)
            HomeButton(
              name: sub.name ?? '',
              description: sub.description ?? '',
              classify: navigation.className ?? '',
              icon: sub.icon ?? '',
              id: sub.id ?? 0,
              version: sub.version ?? 0,
              route: sub.routeSrc ?? '',
              hasPermission: isTestUrl() || userInfo?.number == '013600'
                  ? true
                  : sub.hasPermission ?? false,
            )
        ];
        list.add(HomeButtonGroup(
          name: fun.name ?? '',
          description: fun.description ?? '',
          classify: navigation.className ?? '',
          icon: fun.icon ?? '',
          functionGroup: [
            ...subList.where((v) => v.hasPermission),
            ...subList.where((v) => !v.hasPermission)
          ],
        ));
      } else {
        list.add(HomeButton(
          name: fun.functionGroup![0].name ?? '',
          description: fun.functionGroup![0].description ?? '',
          classify: navigation.className ?? '',
          icon: fun.functionGroup![0].icon ?? '',
          id: fun.functionGroup![0].id ?? 0,
          version: fun.functionGroup![0].version ?? 0,
          route: fun.functionGroup![0].routeSrc ?? '',
          hasPermission: isTestUrl() || userInfo?.number == '013600'
              ? true
              : fun.functionGroup![0].hasPermission ?? false,
        ));
      }
    }
    functions.addAll(list);
  }
  return functions;
}
