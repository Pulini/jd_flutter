import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/container_scanner_info.dart';
import 'package:jd_flutter/fun/warehouse/out/forming_packing_scan/packing_scan_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';


class PackingScanPage extends StatefulWidget {
  const PackingScanPage({super.key});

  @override
  State<PackingScanPage> createState() => _PackingScanPageState();
}

class _PackingScanPageState extends State<PackingScanPage> {
  final logic = Get.put(PackingScanLogic());
  final state = Get.find<PackingScanLogic>().state;


  _item(ContainerScanner data) {
    return GestureDetector(
      onTap: () {
        state.getShipmentInformation(
            time: logic.pickerControllerDate
                .getDateFormatYMD()
                .replaceAll('-', ''),
            cabinetNumber: data.cabinetNumber, isGo: true,
       );
      },
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: _text(
                //柜号
                  mes: data.cabinetNumber?? '',
                  backColor: Colors.white,
                  head: false,
                  paddingNumber: 5)),
          Expanded(
              flex: 2,
              child: _text(
                //已发/应出
                  mes: '${data.isSued?? ''}/${data.shouldRelease?? ''}',
                  backColor: Colors.white,
                  head: false,
                  paddingNumber: 5)),
        ],
      ),
    );
  }

  _text({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 0.5, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            maxLines: 1,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  _title() {
    const borders = BorderSide(color: Colors.grey, width: 1);
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            border: const Border(top: borders, left: borders, right: borders),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: _text(
                    //柜号
                      mes: 'packing_shipment_title_cabinet_number'.tr,
                      backColor: Colors.blueAccent.shade100,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                    //已发/应出
                      mes: 'packing_shipment_issued'.tr,
                      backColor: Colors.blueAccent.shade100,
                      head: true,
                      paddingNumber: 5)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'packing_shipment_title'.tr,
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: DatePicker(pickerController: logic.pickerControllerDate),
          ),
          const SizedBox(
            height: 10,
          ),
          _title(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.dataList.length,
                itemBuilder: (BuildContext context, int index) =>
                    _item(state.dataList.toList()[index]),
              ),
            ),
          )
        ]));
  }

@override
void initState() {
  state.getAllData(
      time: logic.pickerControllerDate.getDateFormatYMD().replaceAll('-', ''),
      error: (msg) => errorDialog(content: msg));
  super.initState();
}

  @override
  void dispose() {
    Get.delete<PackingScanLogic>();
    super.dispose();
  }
}
