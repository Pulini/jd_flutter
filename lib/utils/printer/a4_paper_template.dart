// List<Widget> createA4Paper(PickingMaterialOrderPrintInfo data) {
//   //创建表格列item
//   Widget paperTableRow(int flex, String text, CrossAxisAlignment alignment) =>
//       Expanded(
//         flex: flex,
//         child: Container(
//           height: double.infinity,
//           padding: const EdgeInsets.only(left: 5, right: 5),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black, width: 0.5),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: alignment,
//             children: [
//               Text(
//                 text,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       );
//
//   //创建表格行item
//   Widget paperTableLine({
//     required Color backgroundColor,
//     required String? materialCode,
//     required String? materialName,
//     required String? colorSystem,
//     required String? location,
//     required String? unit,
//     required String? contractOweQty,
//     required String? shouldInventoryQty,
//     required String? actualInventoryQty,
//     required String? picking,
//     required String? actual,
//   }) =>
//       Container(
//         height: 29,
//         color: backgroundColor,
//         child: Row(
//           children: [
//             paperTableRow(3, materialCode ?? '', CrossAxisAlignment.start),
//             paperTableRow(11, materialName ?? '', CrossAxisAlignment.start),
//             paperTableRow(3, colorSystem ?? '', CrossAxisAlignment.start),
//             paperTableRow(3, location ?? '', CrossAxisAlignment.start),
//             paperTableRow(1, unit ?? '', CrossAxisAlignment.center),
//             paperTableRow(2, contractOweQty ?? '', CrossAxisAlignment.end),
//             paperTableRow(2, shouldInventoryQty ?? '', CrossAxisAlignment.end),
//             paperTableRow(2, actualInventoryQty ?? '', CrossAxisAlignment.end),
//             paperTableRow(2, picking ?? '', CrossAxisAlignment.end),
//             paperTableRow(2, actual ?? '', CrossAxisAlignment.end),
//           ],
//         ),
//       );
//
//   //创建纸张
//   Widget createPaper({
//     required List<Widget> item,
//     required int page,
//     required int totalPage,
//     required double paperWidth,
//     required double paperHeight,
//     required double paperPadding,
//     required double paperTitleHeight,
//     required double paperSubTitleHeight,
//     required double paperFooterHeight,
//     required String orderNumber,
//     required String contractNo,
//     required String factoryName,
//     required String supplierName,
//   }) =>
//       Container(
//         padding: EdgeInsets.all(paperPadding),
//         width: paperWidth,
//         height: paperHeight,
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(
//               height: paperTitleHeight,
//               child: const Center(
//                 child: Text(
//                   '仓库备料单',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: paperSubTitleHeight,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '领料单号：$orderNumber',
//                     style: const TextStyle(fontSize: 20, color: Colors.black),
//                   ),
//                   Text(
//                     '合同号：$contractNo',
//                     style: const TextStyle(fontSize: 20, color: Colors.black),
//                   ),
//                   Text(
//                     '工厂：$factoryName',
//                     style: const TextStyle(fontSize: 20, color: Colors.black),
//                   ),
//                   Text(
//                     '供应商：$supplierName',
//                     style: const TextStyle(fontSize: 20, color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black, width: 0.5),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: item,
//               ),
//             ),
//             Expanded(child: Container()),
//             Container(
//               height: paperFooterHeight,
//               padding: const EdgeInsets.only(right: 5),
//               child: Row(
//                 children: [
//                   Text(
//                     '打印日期：${getDateYMD()} ${getTimeHms()}',
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 12,
//                     ),
//                     textAlign: TextAlign.end,
//                   ),
//                   const SizedBox(width: 50),
//                   Text(
//                     '打印人：(${userInfo?.number})${userInfo?.name}',
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 12,
//                     ),
//                     textAlign: TextAlign.end,
//                   ),
//                   const Expanded(child: Center()),
//                   Text(
//                     '页码：$page/$totalPage',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       fontSize: 12,
//                     ),
//                     textAlign: TextAlign.end,
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       );
//
//   var scale = 0.5; //纸张缩放比例
//   double paperHeight = 2380 * scale; //A4纸高度
//   double paperWidth = 3368 * scale; //A4纸宽度
//   double paperTitleHeight = 30; //标题高度
//   double paperSubTitleHeight = 25; //子标题高度
//   double paperFooterHeight = 20; //底部高度
//   double paperPadding = 20; //纸张内边距
//   //表格高度
//   double tableHeight = paperHeight -
//       paperTitleHeight -
//       paperSubTitleHeight -
//       paperFooterHeight -
//       paperPadding * 2;
//
//   var widgetList = <List<dynamic>>[];
//
//   //根据仓库进行物料分类
//   var warehouseList = <List<PickingMaterialOrderPrintMaterialInfo>>[];
//   groupBy(data.materialList!, (v) => v.warehouseNumber ?? '').forEach((k, v) {
//     warehouseList.add(v);
//   });
//
//   //根据物料组进行表格行控件的创建
//   for (var item1 in warehouseList) {
//     //添加仓库行
//     widgetList.add([
//       30,
//       Container(
//         height: 29,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.black, width: 0.5),
//         ),
//         padding: const EdgeInsets.only(left: 5, right: 5),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '仓库：${item1[0].warehouseName}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.black,
//               ),
//             )
//           ],
//         ),
//       )
//     ]);
//     //添加表头行
//     widgetList.add([
//       30,
//       paperTableLine(
//         backgroundColor: Colors.grey.shade400,
//         materialCode: '物料编号',
//         materialName: '物料描述',
//         colorSystem: '色系',
//         location: '库位',
//         unit: '单位',
//         contractOweQty: '合同欠数',
//         shouldInventoryQty: '应备货数',
//         actualInventoryQty: '实备货数',
//         picking: '应领料数',
//         actual: '实领料数',
//       )
//     ]);
//     //添加表头行下方空白
//     widgetList.add([
//       30]);
//     //添加物料行
//     for (var i = 0; i < item1.length; ++i) {
//       widgetList.add([
//         30,
//         paperTableLine(
//           backgroundColor: i % 2 == 0 ? Colors.white : Colors.grey.shade200,
//           materialCode: item1[i].materialCode,
//           materialName: item1[i].materialName,
//           colorSystem: item1[i].colorInfo,
//           location: item1[i].location,
//           unit: item1[i].basicUnit,
//           contractOweQty: item1[i].contractOweQty.toShowString(),
//           shouldInventoryQty: item1[i].shouldInventoryQty.toShowString(),
//           actualInventoryQty: '',
//           picking: item1[i].totalInventoryQty.toShowString(),
//           actual: '',
//         )
//       ]);
//     }
//   }
//
//   //控件总高度
//   int totalHeight =
//       widgetList.map((v) => (v[0] as int)).reduce((a, b) => a + b);
//   var page = 1; //页码
//   var totalPage = (totalHeight / tableHeight).ceil(); //总页数
//   var height = 0.0; //当前控件总高度
//   var item = <Widget>[]; //已添加的控件列表
//   var paperList = <Widget>[]; //纸张列表
//
//   //累加控件行，并根据高度判断是否进行分页。
//   for (var w in widgetList) {
//     if (height + w[0] <= tableHeight) {
//       //控件高度小于纸张高度，累加控件
//       height += w[0];
//       item.add(w[1]);
//       if (widgetList.last == w) {
//         //控件累加完毕，创建纸张
//         paperList.add(createPaper(
//           item: item,
//           page: page,
//           totalPage: totalPage,
//           paperWidth: paperWidth,
//           paperHeight: paperHeight,
//           paperPadding: paperPadding,
//           paperTitleHeight: paperTitleHeight,
//           paperSubTitleHeight: paperSubTitleHeight,
//           paperFooterHeight: paperFooterHeight,
//           orderNumber: data.orderNumber ?? '',
//           contractNo: data.contractNo ?? '',
//           factoryName: data.factoryName ?? '',
//           supplierName: data.supplierName ?? '',
//         ));
//         item = [];
//       }
//     } else {
//       //控件高度大于纸张高度，创建纸张，进行分页。
//       height = 0.0;
//       item.add(w[1]);
//       paperList.add(createPaper(
//         item: item,
//         page: page,
//         totalPage: totalPage,
//         paperWidth: paperWidth,
//         paperHeight: paperHeight,
//         paperPadding: paperPadding,
//         paperTitleHeight: paperTitleHeight,
//         paperSubTitleHeight: paperSubTitleHeight,
//         paperFooterHeight: paperFooterHeight,
//         orderNumber: data.orderNumber ?? '',
//         contractNo: data.contractNo ?? '',
//         factoryName: data.factoryName ?? '',
//         supplierName: data.supplierName ?? '',
//       ));
//       page += 1;
//       item = [];
//     }
//   }
//   return paperList;
// }

import 'package:flutter/material.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:qr_flutter/qr_flutter.dart';

List<Widget> createA4Paper2(PickingMaterialOrderPrintInfo data) {
  //创建表格列item
  Widget paperTableRow(int flex, String text, CrossAxisAlignment alignment) =>
      Expanded(
        flex: flex,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: alignment,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

  //创建表格行item
  Widget paperTableLine({
    required bool isTitle,
    required Color backgroundColor,
    required String? typeBody,
    required String? instruction,
    required String? colorSystem,
    required String? size,
    required String? location,
    required String? shouldInventoryQty,
    required String? actualInventoryQty,
    required String? picking,
    required String? actual,
  }) =>
      Container(
        height: 29,
        color: backgroundColor,
        child: Row(
          children: [
            paperTableRow(3, typeBody ?? '', CrossAxisAlignment.center),
            //型体
            paperTableRow(2, instruction ?? '', CrossAxisAlignment.center),
            //指令
            paperTableRow(2, colorSystem ?? '', CrossAxisAlignment.center),
            //色系
            paperTableRow(1, size ?? '', CrossAxisAlignment.center),
            //尺码
            paperTableRow(1, location ?? '', CrossAxisAlignment.center),
            //库位
            paperTableRow(3, shouldInventoryQty ?? '',
                isTitle ? CrossAxisAlignment.center : CrossAxisAlignment.end),
            //应备数
            paperTableRow(3, actualInventoryQty ?? '',
                isTitle ? CrossAxisAlignment.center : CrossAxisAlignment.end),
            //实备数
            paperTableRow(3, picking ?? '',
                isTitle ? CrossAxisAlignment.center : CrossAxisAlignment.end),
            //应领数
            paperTableRow(3, actual ?? '',
                isTitle ? CrossAxisAlignment.center : CrossAxisAlignment.end),
            //实领数
          ],
        ),
      );

  //创建纸张
  Widget createPaper({
    required List<Widget> item,
    required int page,
    required int totalPage,
    required double paperWidth,
    required double paperHeight,
    required double paperPadding,
    required double paperTitleHeight,
    required double paperSubTitleHeight,
    required double paperFooterHeight,
    required String orderNumber,
    required String contractNo,
    required String factoryName,
    required String supplierName,
  }) =>
      Container(
        padding: EdgeInsets.all(paperPadding),
        width: paperWidth,
        height: paperHeight,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: paperTitleHeight,
              child: const Center(
                child: Text(
                  '仓库备料单',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: paperSubTitleHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '单号：$orderNumber',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Text(
                    '合同号：$contractNo',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Text(
                    '工厂：$factoryName',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Text(
                    '领料部门/供应商：$supplierName',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: item,
              ),
            ),
            Expanded(child: Container()),
            Container(
              height: paperFooterHeight,
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                children: [
                  Text(
                    '打印日期：${getDateYMD()} ${getTimeHms()}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(width: 50),
                  Text(
                    '打印人：(${userInfo?.number})${userInfo?.name}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const Expanded(child: Center()),
                  Text(
                    '页码：$page/$totalPage',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  )
                ],
              ),
            )
          ],
        ),
      );

  var scale = 0.5; //纸张缩放比例
  double paperHeight = 2380 * scale; //A4纸高度
  double paperWidth = 3368 * scale; //A4纸宽度
  double paperTitleHeight = 30; //标题高度
  double paperSubTitleHeight = 25; //子标题高度
  double paperFooterHeight = 20; //底部高度
  double paperPadding = 20; //纸张内边距
  //表格高度
  double tableHeight = paperHeight -
      paperTitleHeight -
      paperSubTitleHeight -
      paperFooterHeight -
      paperPadding * 2;

  var widgetList = <List<dynamic>>[];

  //添加表头行
  widgetList.add([
    30,
    paperTableLine(
      backgroundColor: Colors.grey.shade400,
      typeBody: '型体',
      instruction: '指令',
      colorSystem: '色系',
      size: '尺码',
      location: '库位',
      shouldInventoryQty: '应备数',
      actualInventoryQty: '实备数/签名',
      picking: '应领数',
      actual: '实领数/签名',
      isTitle: true,
    )
  ]);

  //添加表头行
  widgetList.add([
    15,
    const SizedBox(
      height: 15,
    )
  ]);

  // 根据物料组进行表格行控件的创建
  for (var item1 in data.materialList!.asMap().entries) {
    //添加物料行
    widgetList.add([
      30,
      Container(
        height: 29,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '物料：(${item1.value.materialCode})${item1.value.materialName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Text(
              '领料员：${item1.value.warehouseKeeper}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      )
    ]);

    //添加物料行
    for (var i = 0; i < item1.value.materialSubList!.length; ++i) {
      widgetList.add([
        30,
        paperTableLine(
          backgroundColor: i % 2 == 0 ? Colors.white : Colors.grey.shade200,
          typeBody: item1.value.materialSubList![i].typeBody,
          instruction: item1.value.materialSubList![i].instruction,
          colorSystem: item1.value.materialSubList![i].colorInfo,
          size: item1.value.materialSubList![i].size,
          location: item1.value.materialSubList![i].warehouseNumber,
          shouldInventoryQty:
              item1.value.materialSubList![i].shouldInventoryQty.toShowString(),
          actualInventoryQty: '',
          picking:
              item1.value.materialSubList![i].totalInventoryQty.toShowString(),
          actual: '',
          isTitle: false,
        )
      ]);
    }

    var allShouldQty = item1.value.materialSubList
        ?.map((v) => v.shouldInventoryQty ?? 0.0)
        .reduce((a, b) => a.add(b));
    var allPicking = item1.value.materialSubList
        ?.map((v) => v.totalInventoryQty ?? 0.0)
        .reduce((a, b) => a.add(b));

    widgetList.add([
      30,
      Container(
        height: 30,
        color: Colors.white,
        child: Row(
          children: [
            paperTableRow(
                9,
                '合同欠数：${item1.value.contractOweQty.toShowString()}',
                CrossAxisAlignment.start), //合同欠数
            paperTableRow(
                3,
                allShouldQty! > 0 ? allShouldQty.toShowString() : '',
                CrossAxisAlignment.end), //应备数
            paperTableRow(3, '', CrossAxisAlignment.end), //实备数
            paperTableRow(3, allPicking! > 0 ? allPicking.toShowString() : '',
                CrossAxisAlignment.end), //应领数
            paperTableRow(3, '', CrossAxisAlignment.end), //实领数
          ],
        ),
      )
    ]);

    if (item1.key != data.materialList!.length - 1) {
      //添加表头行
      widgetList.add([
        30,
        const SizedBox(
          height: 30,
        )
      ]);
    }
  }

  //控件总高度
  int totalHeight =
      widgetList.map((v) => (v[0] as int)).reduce((a, b) => a + b);
  var page = 1; //页码
  var totalPage = (totalHeight / tableHeight).ceil(); //总页数
  var height = 0.0; //当前控件总高度
  var item = <Widget>[]; //已添加的控件列表
  var paperList = <Widget>[]; //纸张列表

  //累加控件行，并根据高度判断是否进行分页。
  for (var w in widgetList) {
    if (height + w[0] <= tableHeight) {
      //控件高度小于纸张高度，累加控件
      height += w[0];
      item.add(w[1]);
      if (widgetList.last == w) {
        //控件累加完毕，创建纸张
        paperList.add(createPaper(
          item: item,
          page: page,
          totalPage: totalPage,
          paperWidth: paperWidth,
          paperHeight: paperHeight,
          paperPadding: paperPadding,
          paperTitleHeight: paperTitleHeight,
          paperSubTitleHeight: paperSubTitleHeight,
          paperFooterHeight: paperFooterHeight,
          orderNumber: data.orderNumber ?? '',
          contractNo: data.contractNo ?? '',
          factoryName: data.factoryName ?? '',
          supplierName: data.supplierName ?? '',
        ));
        item = [];
      }
    } else {
      //控件高度大于纸张高度，创建纸张，进行分页。
      height = 0.0;
      item.add(w[1]);
      paperList.add(createPaper(
        item: item,
        page: page,
        totalPage: totalPage,
        paperWidth: paperWidth,
        paperHeight: paperHeight,
        paperPadding: paperPadding,
        paperTitleHeight: paperTitleHeight,
        paperSubTitleHeight: paperSubTitleHeight,
        paperFooterHeight: paperFooterHeight,
        orderNumber: data.orderNumber ?? '',
        contractNo: data.contractNo ?? '',
        factoryName: data.factoryName ?? '',
        supplierName: data.supplierName ?? '',
      ));
      page += 1;
      item = [];
    }
  }
  return paperList;
}

/// 生成多页A4纸报表
/// paperTitle 单据标题
/// orderType  工单类型
/// palletNumber 托盘号
/// sizeMaterialTable 尺码物料表格数据
///     [
///        指令号(String),
///        单尺码装数据(List),
///        单尺码装总货数(double),
///        单尺码装总件数(int),
///        混码装数据(List),
///        混码装总货数(double),
///        混码装总件数(int),
///     ]
///      单尺码装数据(List)：[{ 尺码: [件货数]}]
///     [
///          { 4.5: [20.0, 20.0] },
///          { 5: [20.0, 20.0] },
///          { 5.5: [20.0] }
///     ]
///      混码装数据(List)：[ { 件码: [ [尺码,数量],[尺码,数量],[尺码,数量]]} ]
///     [
///          { 25092000000013:
///            [
///              [3, 25.0], [4, 25.0], [5, 25.0], [5.5, 25.0],
///            ]
///          },
///          { 25092000000014:
///            [
///              [6.5, 10.0], [7, 10.0]
///            ]
///          },
///          { 25092000000015:
///            [
///              [3, 20.0], [3.5, 20.0], [4, 20.0]
///            ]
///          }
///     ]
/// materialTable  物料表格数据
/// [
///   [
///     物料代码,
///     单位,
///     [10,20,30,40],
///   ],
///   [
///     物料代码,
///     单位,
///     [10,20,30,40],
///   ],
/// ]
List<Widget> createA4PaperMaterialList({
  required String paperTitle,
  required String factoryName,
  required String orderType,
  required String customsDeclarationType,
  required String palletNumber,
  required List<List> sizeMaterialTable,
  required List<List> materialTable,
}) {
  var scale = 0.5; //纸张缩放比例
  double paperWidth = 2380 * scale; //A4纸高度
  double paperHeight = 3368 * scale; //A4纸宽度
  double paperPadding = 20; //纸张内边距
  double paperTitleHeight = 140; //表头高度
  double paperFooterHeight = 40; //底部分页行高度
  //表格高度
  double tableHeight =
      paperHeight - paperTitleHeight - paperFooterHeight - paperPadding * 2;
  //表格宽度
  double tableWidth = paperWidth - paperPadding * 2;

  //控件列表
  var widgetList = <List>[];
  //表格单码装总数
  double singleListTotalQty = 0.0;
  //表格单码装总件数
  int singleListTotalPiece = 0;
  //表格混码装总数
  double mixListTotalQty = 0.0;
  //表格混码装总件数
  int mixListTotalPiece = 0;

  for (var sub in sizeMaterialTable) {
    _createSizeMaterialTable(
      tableData: sub,
      callback: (tableWidget, line) =>
          widgetList.add([line * (40 + 2), tableWidget]),
    );
    singleListTotalQty = singleListTotalQty.add((sub[2] as double));
    singleListTotalPiece += (sub[3] as int);
    mixListTotalQty = mixListTotalQty.add((sub[5] as double));
    mixListTotalPiece += (sub[6] as int);
  }
  //根据指令大小进行排序
  widgetList.sort((a, b) => (a.first as int).compareTo((b.first as int)));
  //末尾合计行
  widgetList.add([
    40 + 2,
    Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Row(children: [
        _borderText(text: '合计', flex: 37),
        _borderText(
          text: singleListTotalQty.add(mixListTotalQty).toShowString(),
          flex: 5,
        ),
        _borderText(
          text: (singleListTotalPiece + mixListTotalPiece).toString(),
          flex: 5,
        ),
      ]),
    )
  ]);

  if (materialTable.isNotEmpty) {
    widgetList.add([
      60,
      Container(
        height: 60,
      )
    ]);
    widgetList.add([
      40 + 2,
      Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.black, width: 1),
            top: BorderSide(color: Colors.black, width: 1),
            right: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: Row(children: [
          _borderText(text: '序号', flex: 2),
          _borderText(text: '物料代码', flex: 16),
          _borderText(text: '件数', flex: 2),
          _borderText(text: '数量', flex: 5),
          _borderText(text: '单位', flex: 2),
        ]),
      ),
    ]);
  }
  for (var i = 0; i < materialTable.length; ++i) {
    _createMaterialTable(
      index: i,
      tableWidth: tableWidth,
      tableData: materialTable[i],
      callback: (tableWidget, height) => widgetList.add([height, tableWidget]),
    );
  }

  logger.f(widgetList);

  var paperList = <Widget>[]; //纸张列表
  List<List<Widget>> pages = [];
  List<Widget> currentPage = [];
  int currentPageHeight = 0;

  for (var widgetItem in widgetList) {
    int widgetHeight = widgetItem[0] as int;
    Widget widget = widgetItem[1] as Widget;

    // 如果当前控件加入后会超出页面高度
    if (currentPageHeight + widgetHeight > tableHeight) {
      // 保存当前页
      if (currentPage.isNotEmpty) {
        pages.add(List<Widget>.from(currentPage));
      }
      // 开始新页面
      currentPage = [widget];
      currentPageHeight = widgetHeight;
    } else {
      // 添加到当前页
      currentPage.add(widget);
      currentPageHeight += widgetHeight;
    }
  }

  // 添加最后一页
  if (currentPage.isNotEmpty) {
    pages.add(currentPage);
  }

// 然后为每组创建纸张
  for (int i = 0; i < pages.length; i++) {
    paperList.add(_createPaper(
      paperWidth: paperWidth,
      paperHeight: paperHeight,
      tablePadding: paperPadding,
      tableTitleHeight: paperTitleHeight,
      tableFooterHeight: paperFooterHeight,
      palletNumber: palletNumber,
      title: paperTitle,
      factoryName: factoryName,
      orderType: orderType,
      customsDeclarationType: customsDeclarationType,
      qrCode: palletNumber,
      item: pages[i],
      page: i + 1,
      totalPage: pages.length,
    ));
  }
  return paperList;
}

/// 创建A4纸报表
/// paperWidth  纸张宽度
/// paperHeight 纸张高度
/// tablePadding  表格边距
/// tableTitleHeight  标题头高度
/// tableFooterHeight 结尾页码高度
/// palletNumber  托盘编号
/// title 标题文本
/// factoryName 原料工厂名称
/// orderType 单据类型
/// customsDeclarationType 报关形式
/// qrCode  二维码内容
/// item  表格行块
/// page  当前页码
/// totalPage 总页数
Widget _createPaper({
  required double paperWidth,
  required double paperHeight,
  required double tablePadding,
  required double tableTitleHeight,
  required double tableFooterHeight,
  required String palletNumber,
  required String title,
  required String factoryName,
  required String orderType,
  required String customsDeclarationType,
  required String qrCode,
  required List<Widget> item,
  required int page,
  required int totalPage,
}) =>
    Container(
      padding: EdgeInsets.all(tablePadding),
      width: paperWidth,
      height: paperHeight,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: tableTitleHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 35,
                  left: 0,
                  right: tableTitleHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customsDeclarationType,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '原料厂区：$factoryName',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        orderType,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: tableTitleHeight + 10,
                  child: Text(
                    '${userInfo?.name}(${getPrintTime()})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: QrImageView(
                          data: qrCode,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(
                        palletNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...item,
          Expanded(child: Container()),
          SizedBox(
            height: tableFooterHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$page / $totalPage',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );

///创建带边框的文本
/// text  文本内容
/// flex  Expanded占比
/// style 字体样式
/// titleAlignment  文本对齐方向
/// padding 文本框内边距
Widget _borderText({
  required String text,
  int? flex,
  TextStyle? style,
  Alignment? titleAlignment,
  EdgeInsets? padding,
}) {
  var widget = Container(
    height: 40,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 1),
    ),
    padding: padding ?? const EdgeInsets.only(left: 3, right: 3),
    alignment: titleAlignment ?? Alignment.center,
    child: Text(
      text,
      style:
          style ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
    ),
  );
  return flex == null ? widget : Expanded(flex: flex, child: widget);
}

/// 创建尺码物料表格
/// tableData: 表格数据
/// sizeMaterialTable 尺码物料表格数据：
///     [
///        指令号(String),
///        单尺码装数据(List),
///        单尺码装总货数(double),
///        单尺码装总件数(int),
///        混码装数据(List),
///        混码装总货数(double),
///        混码装总件数(int),
///     ]
///      单尺码装数据(List)：[{ 尺码: [件货数]}]
///     [
///          { 4.5: [20.0, 20.0] },
///          { 5: [20.0, 20.0] },
///          { 5.5: [20.0] }
///     ]
///      混码装数据(List)：[ { 件码: [ [尺码,数量],[尺码,数量],[尺码,数量]]} ]
///     [
///          { 25092000000013:
///            [
///              [3, 25.0], [4, 25.0], [5, 25.0], [5.5, 25.0],
///            ]
///          },
///          { 25092000000014:
///            [
///              [6.5, 10.0], [7, 10.0]
///            ]
///          },
///          { 25092000000015:
///            [
///              [3, 20.0], [3.5, 20.0], [4, 20.0]
///            ]
///          }
///     ]
/// callback: 回调 表格widget 行数
void _createSizeMaterialTable({
  required List tableData,
  required Function(Widget, int) callback,
}) {
  //尺码列数
  int column = 7;
  //表格头指令号
  String ins = tableData[0];
  //表格单码装数据
  List<Map<String, List<double>>> singleDataList = tableData[1];
  //表格单码装总数
  double singleListTotalQty = tableData[2];
  //表格单码装总件数
  int singleListTotalPiece = tableData[3];
  //表格混码装数据
  List<Map<String, List<List>>> mixDataList = tableData[4];
  //表格混码装总数
  double mixListTotalQty = tableData[5];
  //表格混码装总件数
  int mixListTotalPiece = tableData[6];
  //需要根据列数拆分成多少组
  var singleGroupCount = (singleDataList.length / column).ceil();
  //需要根据列数拆分成多少组
  var mixGroupCount = (mixDataList.length / column).ceil();
  //拆分重组单码装数据
  var singleDataGroupList = List.generate(
    singleGroupCount,
    (i) {
      var start = i * column;
      var end = (start + column < singleDataList.length)
          ? start + column
          : singleDataList.length;
      return singleDataList.sublist(start, end);
    },
  );

  //如果最后一组数据不足列数，则填充空数据
  for (var i = 0; i < singleGroupCount; i++) {
    if (singleDataGroupList[i].length < column) {
      singleDataGroupList[i].addAll(
        List.generate(
          column - singleDataGroupList[i].length,
          (index) => {},
        ),
      );
    }
  }

  List<Map<String, List<List<List>>>> mixDataGroupList = [];

  for (var piece in mixDataList) {
    var pieceNo = piece.keys.first;
    var sizeList = piece.values.first.toList();
    //拆分重组单码装数据
    var list = sizeList.length > column
        ? List.generate(
            mixGroupCount,
            (i) {
              var start = i * column;
              var end = (start + column < sizeList.length)
                  ? start + column
                  : sizeList.length;
              return sizeList.sublist(start, end);
            },
          )
        : [sizeList];

    //如果最后一组数据不足列数，则填充空数据
    for (var i = 0; i < mixGroupCount; i++) {
      if (list.first.length < column) {
        list[i].addAll(
          List.generate(
            column - list[i].length,
            (index) => [],
          ),
        );
      }
    }
    list.removeWhere((v) =>
        v.every((v2) => v2.isEmpty || v2.last.toString().toDoubleTry() == 0));
    mixDataGroupList.add({pieceNo: list});
  }

  var singleMaterialWidget = singleDataGroupList.isEmpty
      ? Container()
      : IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  alignment: Alignment.center,
                  child: const Text(
                    '单',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ),
              ),
              Expanded(
                flex: column * 4,
                child: Column(
                  children: [
                    for (var item in singleDataGroupList)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var line in item)
                              Expanded(
                                child: Column(
                                  children: line.isEmpty ||
                                          line.values.first.isEmpty
                                      ? [
                                          _borderText(text: '', flex: 1),
                                          _borderText(text: '', flex: 1),
                                          _borderText(text: '', flex: 1),
                                        ]
                                      : [
                                          _borderText(
                                            text: '${line.keys.first}#',
                                            flex: 1,
                                          ),
                                          _borderText(
                                            text: line.values.first.isEmpty
                                                ? ''
                                                : line.values.first
                                                    .map((v) => v)
                                                    .reduce((a, b) => a.add(b))
                                                    .toShowString(),
                                            flex: 1,
                                          ),
                                          _borderText(
                                            text: line.values.first.isEmpty
                                                ? ''
                                                : line.values.first.length
                                                    .toString(),
                                            flex: 1,
                                          ),
                                        ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _borderText(
                      text: '双数',
                      flex: 0,
                    ),
                    _borderText(
                      text: singleListTotalQty.toShowString(),
                      flex: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _borderText(
                      text: '件数',
                      flex: 0,
                    ),
                    _borderText(
                      text: singleListTotalPiece.toString(),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

  var mixMaterialWidget = mixDataGroupList.isEmpty
      ? Container()
      : IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  alignment: Alignment.center,
                  child: const Text(
                    '混',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ),
              ),
              Expanded(
                flex: column * 4 + 5 * 2,
                child: Column(
                  children: [
                    for (var item in mixDataGroupList)
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              flex: column * 4,
                              child: Column(
                                children: [
                                  for (var line in item.values.first) ...[
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          for (var sub in line)
                                            _borderText(
                                              text: sub.isEmpty ||
                                                      sub.last
                                                              .toString()
                                                              .toDoubleTry() ==
                                                          0
                                                  ? ''
                                                  : '${sub.first}#',
                                              flex: 2,
                                            ),
                                        ],
                                      ),
                                    ),
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          for (var sub in line)
                                            _borderText(
                                              text: sub.isEmpty
                                                  ? ''
                                                  : (sub.last as double) == 0
                                                      ? ''
                                                      : (sub.last as double)
                                                          .toShowString(),
                                              flex: 2,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                alignment: Alignment.center,
                                child: Text(
                                  item.values
                                      .toList()
                                      .map((v) => v.first
                                          .map((v2) => v2.isEmpty
                                              ? 0.0
                                              : v2.last
                                                  .toString()
                                                  .toDoubleTry())
                                          .reduce((a, b) => a.add(b)))
                                      .reduce((a, b) => a.add(b))
                                      .toShowString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                alignment: Alignment.center,
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

  var tableWidget = Container(
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.black, width: 1),
        right: BorderSide(color: Colors.black, width: 1),
      ),
    ),
    child: Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _borderText(text: '指令号'),
                    _borderText(text: ins, flex: 1),
                  ],
                ),
              ),
              Expanded(
                flex: 40,
                child: Column(
                  children: [
                    singleMaterialWidget,
                    mixMaterialWidget,
                  ],
                ),
              )
            ],
          ),
        ),
        Row(children: [
          _borderText(text: '小计', flex: 37),
          _borderText(
            text: singleListTotalQty.add(mixListTotalQty).toShowString(),
            flex: 5,
          ),
          _borderText(
            text: (singleListTotalPiece + mixListTotalPiece).toString(),
            flex: 5,
          ),
        ]),
      ],
    ),
  );
  callback.call(
    tableWidget,
    singleGroupCount * 3 +
        mixDataGroupList.length * 2 +
        1, //单码每组3行 + 混码每组2行 + 1组小计
  );
}

///创建物料表格
/// index 索引
/// tableWidth  表格宽度
/// tableData   表格数据
///   [
///       物料代码,
///       单位,
///       [10,20,30,40],
///   ],
/// callback: 回调 表格widget 行数
void _createMaterialTable({
  required int index,
  required double tableWidth,
  required List tableData,
  required Function(Widget, int) callback,
}) {
  String materialCode = tableData.first;
  String unit = tableData[1];
  List<double> qtyList = tableData[2];
  double total = qtyList.map((v) => v).reduce((a, b) => a.add(b));
  double expandedWidth = (25 / 27) * tableWidth;
  String text = qtyList.join(' + ');
  Size textSize = getTextSize(text: text, maxWidth: expandedWidth);
  var tableItem = Container(
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.black, width: 1),
        right: BorderSide(color: Colors.black, width: 1),
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: const EdgeInsets.only(left: 3, right: 3),
              alignment: Alignment.center,
              child: Text(
                (index + 1).toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),
          ),
          Expanded(
            flex: 25,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      _borderText(
                        text: materialCode,
                        flex: 16,
                        titleAlignment: Alignment.centerLeft,
                      ),
                      _borderText(text: qtyList.length.toString(), flex: 2),
                      _borderText(text: total.toShowString(), flex: 5),
                      _borderText(text: unit, flex: 2),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
  debugPrint('tableItem height: ${textSize.height}');
  callback.call(tableItem, (textSize.height).toInt() + 40 + 4);
}

///获取文本尺寸
/// text  文本
/// maxWidth  最大宽度限制
/// style 字体样式
Size getTextSize({
  required String text,
  required double maxWidth,
  TextStyle? style,
}) {
  var textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style:
          style ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  return Size(textPainter.width, textPainter.height);
}
