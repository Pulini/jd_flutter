import 'package:flutter/material.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:jd_flutter/login/phone_login.dart';
import 'package:jd_flutter/login/work_number_login.dart';

import '../reading.dart';
import 'face_login.dart';
import 'machine_login.dart';

/// File Name : login
/// Created by : PanZX on 2023/02/27
/// Email : 644173944@qq.com
/// Github : https://github.com/Pulini
/// Remark：登录页面
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          //设置背景
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            // colors: [Color(0xFFf54b64), Color(0xFFf78361)],
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          )),
          child: ListView(
              //添加登录UI
              children: const [
                SizedBox(height: 50),
                Hero(tag: "logo", child: Logo()),
                SizedBox(height: 40),
                Page(),
              ])),
    );
  }
}


class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with TickerProviderStateMixin {
  late final TabController _tabController;

  var tabs = <Tab>[];
  var tabViews = <Widget>[];

  @override
  void initState() {
    super.initState();
    tabs.add(const Tab(icon: Icon(Icons.phone)));
    tabViews.add(const PhoneLogin());
    if (GetPlatform.isAndroid) {
      tabs.add(const Tab(icon: Icon(Icons.account_circle_outlined)));
      tabViews.add(const FaceLogin());
    }
    tabs.add(const Tab(icon: Icon(Icons.precision_manufacturing)));
    tabs.add(const Tab(icon: Icon(Icons.assignment_ind_outlined)));
    tabViews.add(const MachineLogin());
    tabViews.add(const WorkNumberLogin());
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 340,
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.greenAccent,
              unselectedLabelColor: Colors.white,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: tabs,
            ),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: tabViews,
            ),
          ),
        ],
      ),
    );
  }
}
