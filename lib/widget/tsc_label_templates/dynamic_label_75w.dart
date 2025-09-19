import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

//标签表格格式化
List<List<String>> _labelTableFormat({
  required String title,
  String? total,
  required Map<String, List<List<String>>> list,
}) {
  List<List<String>> result = [];
  // 取出所有尺码
  List<String> titleList = [];
  List<String> columnsTitleList = [];

  list.forEach((k, v) {
    for (var t in v) {
      if (!titleList.contains(t[0])) {
        titleList.add(t[0]);
      }
    }
  });

  titleList.sort((a, b) => a.toDoubleTry().compareTo(b.toDoubleTry()));

  // 指令缺的尺码做补位处理
  list.forEach((k, v) {
    List<List<String>> text = [];
    for (var t in titleList) {
      try {
        text.add(v.firstWhere((v) => v[0] == t));
      } catch (e) {
        text.add([t, '']);
      }
    }
    v.clear();
    v.addAll(text);
  });

  List<List<String>> printList = [];

  // 保存表格列第一格
  columnsTitleList.add(title);
  // 添加表格头行
  printList.add([for (var s in titleList) s]);

  // 添加表格体
  list.forEach((k, v) {
    // 保存表格列第一格
    columnsTitleList.add(k);
    // 添加表格行
    printList.add([for (var data in v) data[1]]);
  });

  if (total != null && total.isNotEmpty) {
    // 保存表格列第一格
    columnsTitleList.add(total);
    var print = <String>[];
    // 保存表格最后一行
    titleList.forEachIndexed((i, v) {
      double sum = 0.0;
      list.forEach((key, value) {
        if (i < titleList.length) {
          sum = sum.add(value[i][1].toDoubleTry());
        }
      });
      print.add(sum.toShowString());
    });
    // 添加表格尾行
    printList.add(print);
  }

  const max = 6;
  final maxColumns = (titleList.length / max).ceil();

  for (int i = 0; i < maxColumns; i++) {
    // 添加表格
    printList.forEachIndexed((index, data) {
      var s = i * max;
      var t = i * max + max;
      List<String> subData = [];
      // 添加行表头
      subData.add(columnsTitleList[index]);
      // 添加行
      subData.addAll(data.sublist(
        s,
        s < data.length && t <= data.length ? t : data.length,
      ));
      result.add(subData);
    });
    if (i < maxColumns - 1) {
      // 加入空行用于区分表格换行
      result.add([]);
    }
  }
  return result;
}

Widget _createTableWidget({
  required String titleText,
  required String totalText,
  required Map<String, List<List<String>>> map,
}) {
  var list = <Widget>[];

  //表格最大行数T
  var maxRow = map.length > 1 ? map.length + 2 : map.length + 1;

  //表格拆分后最大列数
  var maxColumns = 7;

  //表格拆分成列表
  var table = _labelTableFormat(
    title: titleText,
    total: map.length > 1 ? totalText : null,
    list: map,
  );

  for (var i = 0; i < table.length; ++i) {
    list.add(Row(
      children: [
        for (var j = 0; j < table[i].length; ++j)
          expandedFrameText(
            alignment: j == 0
                ? Alignment.centerLeft
                : i == 0 || (table[i].isEmpty ? i - 1 : i) % (maxRow + 1) == 0
                    ? Alignment.center
                    : Alignment.centerRight,
            flex: j == 0 ? 9 : 4,
            padding: j == 0 ? null : const EdgeInsets.all(3),
            isBold: true,
            text: table[i][j],
          ),
        if (maxColumns - table[i].length > 0)
          for (var j = 0; j < maxColumns - table[i].length; ++j)
            Expanded(flex: 4, child: Container()),
      ],
    ));
    if (table[i].isEmpty) list.add(const SizedBox(height: 10));
  }
  return Padding(
    padding: const EdgeInsets.only(left: 5, right: 5),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    ),
  );
}

///动态格式标签模版
///75 x N（高度由内容决定）
Widget _dynamicLabelTemplate75xN({
  required String qrCode,
  bool isBig = false,
  Widget? title,
  Widget? subTitle,
  Widget? header,
  Widget? table,
  Widget? footer,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var titleWidget = Container(
    decoration: BoxDecoration(border: Border(bottom: bs)),
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
                  child: title ?? const Text(''),
                ),
              ),
              Expanded(
                flex: 3,
                child: subTitle ?? const Text(''),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return Container(
    color: Colors.white,
    width: isBig ? 108 * 5.5 : 75 * 5.5,
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
            SizedBox(
              height: isBig? 27 * 5.5 :19 * 5.5,
              child: titleWidget,
            ),
            if (header != null) header,
            if (table != null) ...[
              const SizedBox(height: 5),
              table,
              const SizedBox(height: 5),
            ],
            if (footer != null) ...[footer, const SizedBox(height: 5)],
          ],
        ),
      ),
    ),
  );
}

///标签维护尺码物料中文标
Widget maintainLabelSizeMaterialChineseDynamicLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required double total,
  required String unit,
  required String materialCode,
  required String materialName,
  required Map<String, List<List<String>>> map,
  required String pageNumber,
  required String deliveryDate,
}) =>
    _dynamicLabelTemplate75xN(
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
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${total.toShowString()}$unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              ],
            ),
            Text(
              '($materialCode)$materialName'.allowWordTruncation(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      table: _createTableWidget(titleText: '尺码', totalText: '合计', map: map),
      footer: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pageNumber,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(
                deliveryDate,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );

///标签维护尺码物料英文标
Widget maintainLabelSizeMaterialEnglishDynamicLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required String materialCode,
  required String materialName,
  required double grossWeight,
  required double netWeight,
  required String meas,
  required double total,
  required String unit,
  required Map<String, List<List<String>>> map,
  required String pageNumber,
  required String deliveryDate,
}) =>
    _dynamicLabelTemplate75xN(
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
          '($materialCode)$materialName'.allowWordTruncation(),
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GW:${grossWeight.toShowString()}KG',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NW:${netWeight.toShowString()}KG',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'MEAS:$meas ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${total.toShowString()} $unit',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      table:
          _createTableWidget(titleText: 'Size', totalText: 'Total', map: map),
      footer: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pageNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    deliveryDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Made in China',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gold Emperor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

///贴标维护混合中文标签
Widget maintainLabelMixChineseDynamicLabel({
  required String barCode,
  required String factoryType,
  required String billNo,
  required double total,
  required String unit,
  required String materialCode,
  required String materialName,
  required Map<String, List<List<String>>> map,
  required String pageNumber,
  required String deliveryDate,
}) =>
    _dynamicLabelTemplate75xN(
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
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${total.toShowString()} $unit',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
            Text(
              '($materialCode)$materialName'.allowWordTruncation(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      table: _createTableWidget(titleText: '尺码', totalText: '合计', map: map),
      footer: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pageNumber,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(
                deliveryDate,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );

///贴标维护混合英文标签
Widget maintainLabelMixEnglishDynamicLabel({
  required String barCode,
  required String factoryType,
  required String materialCode,
  required String materialName,
  required double grossWeight,
  required double netWeight,
  required String meas,
  required double total,
  required String unit,
  required Map<String, List<List<String>>> map,
  required String pageNumber,
  required String deliveryDate,
}) =>
    _dynamicLabelTemplate75xN(
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
          '($materialCode)$materialName'.allowWordTruncation(),
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      header: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GW:${grossWeight.toShowString()}KG',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NW:${netWeight.toShowString()}KG',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'MEAS:$meas ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${total.toShowString()} $unit',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      table:
          _createTableWidget(titleText: 'Size', totalText: 'Total', map: map),
      footer: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pageNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    deliveryDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Made in China',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gold Emperor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

///材料车间动态标签
Widget materialWorkshopDynamicLabel({
   bool isBig = false,
  required String qrCode,
  required String productName,
  required String materialName,
  required String partName,
  required String materialNumber,
  required String processName,
  required List<String> subList,
  required String sapDecideArea,
  required String color,
  required String drillingCrewName,
  required String qty,
  required String unitName,
}) {
  var textStyle =   TextStyle(fontSize: isBig?10 :8,fontWeight:FontWeight.bold);
  return _dynamicLabelTemplate75xN(
    isBig: isBig,
    qrCode: qrCode,
    title: Text(productName, style: TextStyle(fontWeight:FontWeight.bold,fontSize:isBig ? 23: 18)),
    subTitle: Text(materialName, style: textStyle),
    header: Text('部件：$partName($materialNumber)<$processName>',style:  TextStyle(fontSize: isBig?14 : 10,fontWeight:FontWeight.bold),),
    table: Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var s in subList) Text(s, style: TextStyle(fontSize: isBig? 13 : 9,fontWeight:FontWeight.bold))
        ],
      ),
    ),
    footer: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(sapDecideArea, style: textStyle)),
            Expanded(child: Text('色系：$color', style: textStyle))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(drillingCrewName, style: textStyle),
            ),
            Expanded(
              child: Text('数量：$qty$unitName', style: textStyle),
            )
          ],
        )
      ],
    ),
  );
}
