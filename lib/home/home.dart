import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/home/user_setting.dart';
import 'package:jd_flutter/utils.dart';

import '../constant.dart';
import '../generated/l10n.dart';
import '../http/response/user_info.dart';
import '../http/web_api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  int _selectedIndex = 0;

  final _widgetOptions = [
    Text(S.current.home_bottom_bar_produce),
    Text(S.current.home_bottom_bar_warehouse),
    Text(S.current.home_bottom_bar_manage),
  ];

  // Widget userImage = const Icon(Icons.flutter_dash, color: Colors.white);

  void _gotoDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserSetting(user: user!)),
    ).then((path) => {
          if (path.isNotEmpty)
            setState(() {
              userImage = Image.asset(path);
            })
        });
  }

  UserInfo? user;
  late Widget userImage = const Icon(Icons.flutter_dash, color: Colors.white);

  @override
  void initState() {
    super.initState();
    userInfo().then((value) {
      setState(() {
        user = value;
        if (user!.picUrl?.isNotEmpty == true) {
          userImage = ClipOval(child: Image.network(user!.picUrl!));
        }
      });
    });
    _initJPushListener();
  }

  _initJPushListener() {
    const MethodChannel(androidPackageName).setMethodCallHandler((call) {
      logger.wtf("JMessage：$call");
      switch (call.method) {
        case "JMessage":
          {
            String msg = call.arguments["json"];
          }
          break;
      }
      return Future.value(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: const Text('Gold Emperor'),
            titleTextStyle: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: Hero(
                  tag: "user",
                  child: userImage,
                ),
                onPressed: () {
                  _gotoDetailsPage(context);
                },
              )
            ]),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: const Icon(Icons.display_settings),
                label: S.current.home_bottom_bar_produce,
                backgroundColor: const Color.fromARGB(0xff, 0x99, 0xcc, 0x66)),
            BottomNavigationBarItem(
                icon: const Icon(Icons.factory_outlined),
                label: S.current.home_bottom_bar_warehouse,
                backgroundColor: const Color.fromARGB(0xff, 0xff, 0x66, 0x66)),
            BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_outlined),
                label: S.current.home_bottom_bar_manage,
                backgroundColor: const Color.fromARGB(0xff, 0x00, 0x99, 0xcc)),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(0xff, 0xff, 0xff, 0x66),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
