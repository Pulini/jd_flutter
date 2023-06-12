import 'package:flutter/material.dart';
import 'package:jd_flutter/login/phone_login.dart';
import 'package:jd_flutter/generated/l10n.dart';
import 'package:jd_flutter/utils.dart';

import '../main.dart';
import 'face_login.dart';

/// File Name : login
/// Created by : PanZX on 2023/02/27
/// Email : 644173944@qq.com
/// Github : https://github.com/Pulini
/// Remark：

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          // colors: [Color(0xFFf54b64), Color(0xFFf78361)],
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        )),
        child: Stack(
          children: [
            Positioned(
                key:GlobalKey(),
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Image.asset("lib/res/images/ic_logo.png",
                              width: 130, height: 130),
                          const Text("Gold Emperor",
                              style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none))
                        ],
                      ),
                      const LoginPage(),
                    ])),
            Positioned(
              left: 10,
              bottom: 10,
              child: TextButton(
                onPressed: () {
                  Locale local = Localizations.localeOf(context) == languageZh
                      ? languageEn
                      : languageZh;
                  MyApp.of(context).locale = local;

                  // setState(() {
                  //   var local=Localizations.localeOf(context) == languageZh? languageEn : languageZh;
                  //   print("local:$local");
                  //   S.load(local);
                  // });
                },
                child: Text(
                    Localizations.localeOf(context) == languageZh
                        ? "English"
                        : "中文",
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        width: 350,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: TabBar(
              controller: tabController,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.greenAccent,
              unselectedLabelColor: Colors.white,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: const <Widget>[
                Tab(
                  icon: Icon(Icons.phone),
                ),
                Tab(
                  icon: Icon(Icons.assignment_ind_outlined),
                ),
                Tab(
                  icon: Icon(Icons.precision_manufacturing),
                ),
                Tab(
                  icon: Icon(Icons.account_circle_outlined),
                ),
              ]),
          body: TabBarView(
            controller: tabController,
            children: const <Widget>[
              PhoneLogin(),
              FaceLogin(),
              Center(
                child: Text("It's sunny here"),
              ),
              Center(
                child: Text("It's sunny here"),
              ),
            ],
          ),
        ));
  }
}
