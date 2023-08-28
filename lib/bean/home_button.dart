

import '../route.dart';

abstract class ButtonItem {
  late String name;
  late String description;
  late String icon;
  late int classify;

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
  late String jid;
  bool lock = false;
  bool hasUpdate = false;

  HomeButton({
    required super.name,
    required super.description,
    required super.classify,
    required super.icon,
    required this.id,
    required this.version,
    required this.route,
    required this.jid,
  });
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

var appButtonList = <ButtonItem>[
  ...productionButton,
  ...warehouseButton,
  ...manageButton
];


///生产类功能列表 classify = 0
final productionButton = <ButtonItem>[
  HomeButtonGroup(
    name: '派工',
    description: '车间生产派工',
    classify: 0,
    icon: 'lib/res/images/ic_logo.png',
    functionGroup: [
      HomeButton(
          name: '生产派工',
          description: '针车车间派工及报工',
          classify: 0,
          id: 9,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: '1051101'),
      HomeButton(
          name: '材料车间派工',
          description: '材料车间派工及报工',
          classify: 0,
          id: 10,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: ''),
      HomeButton(
          name: '湿印工序派工',
          description: '湿印车间工序派工',
          classify: 0,
          id: 58,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: ''),
      HomeButton(
          name: '机台派工单',
          description: '贴合车间及注塑车间派工',
          classify: 0,
          id: 65,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: ''),
    ],
  ),
  HomeButtonGroup(
    name: '报表',
    description: '车间生产报表',
    icon: 'lib/res/images/ic_logo.png',
    classify: 0,
    functionGroup: [
      HomeButton(
          name: '扫码日产量报表',
          description: '扫码日产量报表',
          classify: 0,
          id: 9,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: RouteConfig.dailyReport,
          jid: '1051101'),
    ],
  ),
  HomeButton(
      name: '工序汇报',
      description: '工序汇报扫码入库',
      classify: 0,
      id: 3,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '',
      jid: ''),
  HomeButton(
      name: '计件明细',
      description: '员工计件明细表',
      classify: 0,
      id: 4,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '',
      jid: '1051101'),
];

///仓库类功能列表 classify = 1
final warehouseButton = <ButtonItem>[
  HomeButton(
      name: '扫码入库',
      description: '圆盘机入库',
      classify: 1,
      id: 7,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '/page',
      jid: ''),
  HomeButton(
      name: '移库',
      description: '仓库物料转移',
      classify: 1,
      id: 8,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '',
      jid: '1051101'),
  HomeButtonGroup(
    name: '领料',
    description: '机台生产领料',
    classify: 1,
    icon: 'lib/res/images/ic_logo.png',
    functionGroup: [
      HomeButton(
          name: '造粒领料',
          description: '大底车间造粒领料',
          classify: 1,
          id: 5,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: ''),
      HomeButton(
          name: '喷漆领料',
          description: '鞋底喷漆领料',
          classify: 1,
          id: 6,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: '1051101'),
    ],
  ),
];

///管理类功能列表 classify = 2
final manageButton = <ButtonItem>[
  HomeButton(
      name: '财产管理',
      description: '员工名下财产登记及管理',
      classify: 2,
      id: 11,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '',
      jid: '1051101'),
  HomeButtonGroup(
    name: '宿舍管理',
    description: '集团宿舍管理',
    classify: 2,
    icon: 'lib/res/images/ic_logo.png',
    functionGroup: [
      HomeButton(
          name: '水电抄度',
          description: '宿舍水电表抄录',
          classify: 2,
          id: 9,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: '1051101'),
      HomeButton(
          name: '家属登记',
          description: '员工家属信息登记',
          classify: 2,
          id: 10,
          version: 1,
          icon: 'lib/res/images/ic_logo.png',
          route: '',
          jid: ''),
    ],
  ),
  HomeButton(
      name: '来宾登记',
      description: '宾客来访信息登记',
      classify: 2,
      id: 12,
      version: 1,
      icon: 'lib/res/images/ic_logo.png',
      route: '',
      jid: ''),
];
