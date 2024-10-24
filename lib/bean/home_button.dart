import '../route.dart';

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
    for(var r in RouteConfig.routeList){
      if(r.name==route){
        hasUpdate = version > r.version;
        break;
      }
    }
  }
}

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
