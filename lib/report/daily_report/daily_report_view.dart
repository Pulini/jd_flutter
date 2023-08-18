import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant.dart';
import '../../route.dart';
import '../../utils.dart';
import '../../widget/picker/picker_view.dart';
import 'daily_report_logic.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({Key? key}) : super(key: key);

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  final logic = Get.put(DailyReportLogic());
  final state = Get.find<DailyReportLogic>().state;
  var pickerController = PickerController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('扫码日产量报表'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            )
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              // const DrawerHeader(
              //   decoration: BoxDecoration(
              //     color: Colors.blue,
              //   ),
              //   child: Text(
              //     'Drawer Header',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 24,
              //     ),
              //   ),
              // ),
              Picker(
                saveKey: spSavePickerSupplier+RouteConfig.dailyReport,
                buttonName: '公司',
                controller: pickerController,
                getDataList: () => getSapSuppliers(),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  pickerController.enable.value=!pickerController.enable.value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<DailyReportLogic>();
    super.dispose();
  }
}
