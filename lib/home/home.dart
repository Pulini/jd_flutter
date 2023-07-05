import 'package:flutter/material.dart';
import 'package:jd_flutter/utils.dart';

import '../generated/l10n.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  int _selectedIndex = 0;
  String user = "Gold Emperor";

  final _widgetOptions = [
    Text(S.current.home_bottom_bar_produce),
    Text(S.current.home_bottom_bar_warehouse),
    Text(S.current.home_bottom_bar_manage),
  ];

  Widget userImage = const Icon(Icons.flutter_dash, color: Colors.white);

  void _gotoDetailsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Second Page'),
        ),
        body: Center(
          child: Hero(
            tag: "user",
            child: userImage,
          ),
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    userInfo().then((value) {
      setState(() {
        userImage = Image.network(value.picUrl!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(user),
          titleTextStyle: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          backgroundColor: Colors.lightBlue,
          actions: <Widget>[
            IconButton(
              icon: ClipOval(
                child: Hero(
                  tag: "user",
                  child: userImage,
                ),
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
              backgroundColor: const Color.fromARGB(0xff, 0xff, 0x66, 0x66)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.factory_outlined),
              label: S.current.home_bottom_bar_warehouse,
              backgroundColor: const Color.fromARGB(0xff, 0x00, 0x99, 0xcc)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              label: S.current.home_bottom_bar_manage,
              backgroundColor: const Color.fromARGB(0xff, 0x99, 0xcc, 0x66)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(0xff, 0xff, 0xff, 0x66),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
