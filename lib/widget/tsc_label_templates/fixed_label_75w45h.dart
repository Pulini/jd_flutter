import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

///标准格式标签模版
///75*45大小
Widget _fixedLabelTemplate75x45({
  required String qrCode,
  Widget? title,
  Widget? subTitle,
  Widget? content,
  Widget? bottomLeft,
  Widget? bottomMiddle,
  Widget? bottomRight,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var titleWidget = Container(
    decoration: BoxDecoration(
      border: Border(bottom: bs),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(border: Border(right: bs)),
          child: QrImageView(
            data: qrCode,
            padding: const EdgeInsets.all(5),
            version: QrVersions.auto,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(border: Border(bottom: bs)),
                child: Center(
                  child: Text(
                    qrCode,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(border: Border(bottom: bs)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: title ?? const Text(''),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  child: subTitle ?? const Text(''),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  var contentWidget = Container(
    decoration: BoxDecoration(
      border: Border(bottom: bs),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: content ?? const Text(''),
    ),
  );

  var bottomWidget = Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: bs),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: bottomLeft ?? const Text(''),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: bottomMiddle ?? const Text(''),
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: bs),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: bottomRight ?? const Text(''),
          ),
        ),
      ),
    ],
  );

  return Container(
    color: Colors.white,
    width: 75 * 5.5,
    height: 45 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 19, child: titleWidget),
            Expanded(flex: 17, child: contentWidget),
            Expanded(flex: 7, child: bottomWidget),
          ],
        ),
      ),
    ),
  );
}

///料头标
Widget surplusMaterialLabel({
  required String qrCode,
  required String machine,
  required String shift,
  required String startDate,
  required String typeBody,
  required String materialName,
  required String materialCode,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var qrCodeWidget = Container(
    decoration: BoxDecoration(border: Border(right: bs)),
    child: QrImageView(
      data: qrCode,
      padding: const EdgeInsets.all(5),
      version: QrVersions.auto,
    ),
  );
  var detailWidget = Column(
    children: [
      Expanded(
        flex: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 3, right: 3),
          decoration: BoxDecoration(border: Border(bottom: bs)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '机台：$machine',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '班次：$shift',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 3, right: 3),
          decoration: BoxDecoration(border: Border(bottom: bs)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '派工日期：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                startDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 33,
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: Text(
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            '($materialCode)$materialName'.allowWordTruncation(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    ],
  );
  var typeBodyWidget = Container(
    padding: const EdgeInsets.only(left: 3, right: 3),
    decoration: BoxDecoration(border: Border(top: bs)),
    child: Text(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      '型体：$typeBody',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
  return Container(
    color: Colors.white,
    width: 75 * 5.5,
    height: 45 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 38,
                child: Row(
                  children: [
                    Expanded(
                      flex: 38,
                      child: qrCodeWidget,
                    ),
                    Expanded(
                      flex: 35,
                      child: detailWidget,
                    ),
                  ],
                )),
            Expanded(
              flex: 5,
              child: typeBodyWidget,
            ),
          ],
        ),
      ),
    ),
  );
}

///机台派工 中文标签
Widget machineDispatchChineseFixedLabel({
  required String labelID,
  required String factoryType,
  required String processes,
  required String number,
  required String materialName,
  required String dispatchNumber,
  required String decrementNumber,
  required String date,
  required String size,
  required double qty,
  required String unit,
  required String shift,
  required String machine,
  required bool isLastLabel,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelID,
      title: Text(
        factoryType,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            processes,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            '序号:$number',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              materialName.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 2,
            ),
          ),
          Text(
            '派工号:$dispatchNumber',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '递减号:$decrementNumber',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '日期:$date',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
            ],
          )
        ],
      ),
      bottomLeft: Center(
        child: Text(
          '$size#${qty.toShowString()}$unit',
          style: const TextStyle(
              fontWeight: FontWeight.bold, height: 1, fontSize: 16),
        ),
      ),
      bottomMiddle: Center(
        child: Text(
          '班次：$shift 机台：$machine',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomRight: isLastLabel
          ? const Center(
              child: Text('尾',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : Container(),
    );

///机台派工 英文标签
Widget machineDispatchEnglishFixedLabel({
  required String labelID,
  required String factoryType,
  required String englishName,
  required double grossWeight,
  required double netWeight,
  required String specifications,
  required String number,
  required String dispatchNumber,
  required String decrementNumber,
  required String date,
  required double qty,
  required String englishUnit,
  required String size,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelID,
      title: Text(
        factoryType,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            englishName,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              height: 1,
            ),
          )
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GW: ${grossWeight.toShowString()} KG',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                'NW: ${netWeight.toShowString()} KG',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEAS: $specifications',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                'NO: $number',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              ),
            ],
          ),
          Text(
            'DISPATCH: $dispatchNumber',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DECREASE: $decrementNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                'DATE: $date',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1,
                ),
              )
            ],
          )
        ],
      ),
      bottomLeft: Center(
        child: Text(
          '${qty.toShowString()}$englishUnit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomMiddle: const Center(
        child: Text(
          'Made in China',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomRight: Center(
        child: Text(
          '$size#',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );

///湿印工序派工单标签
Widget processDispatchRegisterLabel({
  required String barCode,
  required String typeBody,
  required String processName,
  required String instructionsText,
  required String empNumber,
  required String empName,
  required String size,
  required double mustQty,
  required String unit,
  required int rowID,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: barCode,
      title: Text(
        typeBody,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      subTitle: AutoSizeText(
        processName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        maxLines: 2,
        minFontSize: 12,
        maxFontSize: 36,
      ),
      content: Text(
        instructionsText,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
        ),
        maxLines: 4,
      ),
      bottomLeft: Column(
        children: [
          Expanded(
            child: Text(
              empNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              empName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomMiddle: Center(
        child: Text(
          '$size# ${mustQty.toShowString()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      bottomRight: Center(
        child: Text(
          '序号：$rowID',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );

///贴标维护物料中文标
Widget maintainLabelMaterialChineseFixedLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required String materialCode,
  required String materialName,
  required String pageNumber,
  required double qty,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: barCode,
      title: Text(
        factoryType,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        billNo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              '($materialCode)$materialName'.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
      bottomLeft: Center(
        child: Text(
          pageNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomRight: Column(
        children: [
          Expanded(
            child: Text(
              qty.truncate().toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              unit,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

///贴标维护物料英文标
Widget maintainLabelMaterialEnglishFixedLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required String materialCode,
  required String materialName,
  required double grossWeight,
  required double netWeight,
  required String meas,
  required String pageNumber,
  required double qty,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: barCode,
      title: Text(
        factoryType,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        billNo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              '($materialCode)$materialName'.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 3,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'GW:${grossWeight.toShowString()}KG',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'NW:${netWeight.toShowString()}KG',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'MEAS:$meas',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1,
            ),
          ),
        ],
      ),
      bottomLeft: Center(
        child: Text(
          pageNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomRight: Column(
        children: [
          Expanded(
            child: Text(
              qty.truncate().toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              unit,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

///贴标维护单件尺码中文标
Widget maintainLabelSingleSizeChineseFixedLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required String materialCode,
  required String materialName,
  required String size,
  required String pageNumber,
  required String date,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: barCode,
      title: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Text(
          factoryType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      subTitle: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Text(
          billNo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Text(
                '($materialCode)$materialName',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  height: 1,
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
      bottomLeft: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Center(
          child: Text(
            '$size #',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      bottomMiddle: Column(
        children: [
          Expanded(
            child: Text(
              pageNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomRight: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Center(
          child: Text(
            unit,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );

///贴标维护单件尺码英文标
Widget maintainLabelSingleSizeEnglishFixedLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required String materialCode,
  required String materialName,
  required double grossWeight,
  required double netWeight,
  required String meas,
  required double qty,
  required String pageNumber,
  required String size,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: barCode,
      title: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Text(
          factoryType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      subTitle: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Text(
          billNo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Text(
                '($materialCode)$materialName',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  height: 1,
                ),
                maxLines: 3,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GW:${grossWeight.toShowString()}KG',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NW:${netWeight.toShowString()}KG',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'MEAS:$meas',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1,
              ),
            ),
          ],
        ),
      ),
      bottomLeft: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Center(
          child: Text(
            qty.toShowString()+unit,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      bottomMiddle: Column(
        children: [
          Expanded(
            child: Text(
              pageNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Text(
              'Made in China',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomRight: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: Center(
          child: Text(
            '$size #',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );

///sap wms标签拆分 1101仓库标签
Widget sapWmsSplitLabel1101WarehouseLabel({
  required String labelNumber,
  required String factory,
  required String process,
  required String materialName,
  required String dispatchNumber,
  required String decrementTableNumber,
  required String numPage,
  required String dispatchDate,
  required String dayOrNightShift,
  required String machineNumber,
  required String size,
  required double boxCapacity,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelNumber,
      title: Text(
        factory,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        process,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              materialName.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 2,
            ),
          ),
          Text(
            '派工号:$dispatchNumber',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            '递减号:$decrementTableNumber',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
        ],
      ),
      bottomLeft: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '序号：$numPage',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          Text(
            '产期：$dispatchDate',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
      bottomMiddle: Center(
        child: Text(
          '班次：$dayOrNightShift 机台：$machineNumber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomRight: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '$size#',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          Text(
            '${boxCapacity.toShowString()}$unit',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
    );

///sap wms标签拆分 1102 1105仓库标签
Widget sapWmsSplitLabel1102And1105WarehouseLabel({
  required String labelNumber,
  required String typeBody,
  required String materialCode,
  required String materialName,
  required String numPage,
  required double quantity,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelNumber,
      title: Text(
        typeBody,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        '($materialCode)$materialName'.allowWordTruncation(),
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
          height: 1,
        ),
        maxLines: 3,
      ),
      bottomLeft: Center(
        child: Text(
          '页码：$numPage',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomMiddle: Center(
        child: Text(
          quantity.toShowString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomRight: Center(
        child: Text(
          unit,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );

///sap wms标签拆分 1200仓库标签
Widget sapWmsSplitLabel1200WarehouseLabel({
  required String labelNumber,
  required String typeBody,
  required String instructionNo,
  required String materialCode,
  required String materialName,
  required double grossWeight,
  required double netWeight,
  required String meas,
  required double quantity,
  required String unit,
  required String numPage,
  required String size,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelNumber,
      title: Text(
        typeBody,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        instructionNo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              '($materialCode)$materialName'.allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 2,
            ),
          ),
          Text(
            'GW：${grossWeight.toShowString()}KG NW：${netWeight.toShowString()}KG',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'MEAS: $meas',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
        ],
      ),
      bottomLeft: Center(
        child: Text(
          '${quantity.toShowString()}$unit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      bottomMiddle: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'page：$numPage#',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
          const Text(
            'Made in China',
            style: TextStyle(fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
      bottomRight: Center(
        child: Text(
          '$size#',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );

///sap wms标签拆分 其他仓库标签
Widget sapWmsSplitLabelOtherWarehouseLabel({
  required String labelNumber,
  required String typeBody,
  required String instructionNo,
  required String materialCode,
  required String materialName,
  required String numPage,
  required double quantity,
  required String unit,
}) =>
    _fixedLabelTemplate75x45(
      qrCode: labelNumber,
      title: Text(
        typeBody,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subTitle: Text(
        instructionNo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        '($materialCode)$materialName'.allowWordTruncation(),
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
          height: 1,
        ),
        maxLines: 3,
      ),
      bottomLeft: Text(
        '页码：$numPage',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomMiddle: Text(
        quantity.toShowString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomRight: Text(
        unit,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
