import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'maintain_label_state.dart';

class MaintainLabelLogic extends GetxController {
  final MaintainLabelState state = MaintainLabelState();

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDataList();
    });
    super.onInit();
  }

  refreshDataList() {
    state.getLabelInfoList(error: (msg) => errorDialog(content: msg));
  }

  selectPrinted(bool c) {
    state.cbPrinted.value = c;
    if (state.isMaterialLabel.value) {
      for (var v in state.getLabelList().where((v) => v.isBillPrint ?? false)) {
        v.select = c;
      }
      state.labelList.refresh();
    } else {
      for (var v in state
          .getLabelGroupList()
          .where((v) => v[0].isBillPrint ?? false)) {
        for (var v2 in v) {
          v2.select = c;
        }
      }
      state.labelGroupList.refresh();
    }
  }

  selectUnprinted(bool c) {
    state.cbUnprinted.value = c;
    if (state.isMaterialLabel.value) {
      for (var v
          in state.getLabelList().where((v) => !(v.isBillPrint ?? false))) {
        v.select = c;
      }
      state.labelList.refresh();
    } else {
      for (var v in state
          .getLabelGroupList()
          .where((v) => !(v[0].isBillPrint ?? false))) {
        for (var v2 in v) {
          v2.select = c;
        }
      }
      state.labelGroupList.refresh();
    }
  }

  List<String> getSizeList() {
    var list = <String>['maintain_label_all'.tr];
    if (state.isMaterialLabel.value) {
      for (var v in state.labelList) {
        v.items?.forEach((v2) {
          if (!list.contains(v2.size)) {
            list.add(v2.size ?? '');
          }
        });
      }
    } else {
      for (var v in state.labelGroupList) {
        for (var v2 in v) {
          v2.items?.forEach((v3) {
            if (!list.contains(v3.size)) {
              list.add(v3.size ?? '');
            }
          });
        }
      }
    }

    return list;
  }

  List<String> getSelectData() {
    var list = <String>[];
    if (state.isMaterialLabel.value) {
      state.getLabelList().where((v) => v.select).forEach((data) {
        list.add(data.barCode ?? '');
      });
    } else {
      state.getLabelGroupList().forEach((g) {
        g.where((v) => v.select).forEach((data) {
          list.add(data.barCode ?? '');
        });
      });
    }
    return list;
  }

  createSingleLabel() {
    state.createSingleLabel(
      success: () => refreshDataList(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getBarCodeCount(bool isMix, Function(List<PickingBarCodeInfo>) callback) {
    state.barCodeCount(
      isMix: isMix,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteAllLabel() {
    state.deleteAllLabel(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteLabels(List<String> select) {
    state.deleteLabels(
      select: select,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialProperties(
    Function(RxList<MaintainMaterialPropertiesInfo>) callback,
  ) {
    state.getMaterialProperties(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialCapacity(
    Function(RxList<MaintainMaterialCapacityInfo>) callback,
  ) {
    state.getMaterialCapacity(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialLanguages(
    Function(RxList<MaintainMaterialLanguagesInfo>) callback,
  ) {
    state.getMaterialLanguages(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  printLabelState({
    required List<List<LabelInfo>> selectLabel,
    required int type,
    required String factoryId,
    required Function(int) success,
  }) {
    state.setLabelState(
      selectLabels: selectLabel,
      labelType: type,
      success: (int type) {
        success.call(type);
      },
    );
  }

  checkLanguage({
    required Function(
            String factory, int labelType, List<List<LabelInfo>>, List<String>)
        callback,
  }) {
    var languageList = <String>[];
    var select = <LabelInfo>[];

    if (state.isMaterialLabel.value) {
      for (var data in state.labelGroupList) {
        for (var value in data) {
          if (value.select == true) {
            select.add(value);
          }
        }
      }
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    } else {
      select = state.labelList.where((v) => v.select).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    }

    var labelType = <String>[];

    for (var type in select) {
      if (!labelType.contains(type.labelType.toString())) {
        labelType.add(type.labelType.toString());
      }
    }
    if (labelType.length > 1) {
      errorDialog(content: 'maintain_label_select_label_not_same'.tr);
      return;
    }
    for (var order in select) {
      order.materialOtherName
          ?.where((v) => v.languageName?.isNotEmpty == true)
          .forEach((v) {
        if (!languageList.contains(v.languageName)) {
          languageList.add(v.languageName!);
        }
      });
    }
    if (languageList.isEmpty) {
      errorDialog(content: 'maintain_label_label_language_empty_tips'.tr);
      return;
    }
    for (var language in languageList) {
      for (var label in select) {
        if (label.materialOtherName?.every((v) => v.languageName != language) ==
            true) {
          errorDialog(
            content: 'maintain_label_label_language_lack_tips'.trArgs([
              label.barCode ?? '',
              language,
            ]),
          );
          return;
        }
      }
    }
    callback.call(select[0].fCustomFactoryID!, select[0].labelType!, [select],
        languageList);
  }

  Function(List<Widget>) labelsCallback = (label) {
    if (label.length > 1) {
      Get.to(() => PreviewLabelList(labelWidgets: label));
    } else {
      Get.to(() => PreviewLabel(labelWidget: label[0]));
    }
  };

  printLabel({
    required String factoryId,
    required int type,
    required List<List<LabelInfo>> select,
    String language = '',
  }) {
    if (factoryId.isNotEmpty) {
      switch (factoryId) {
        case '1098':
          {
            if (select[0][0].items!.isNotEmpty) {
              if (select[0][0].items!.length == 1) {
                createSingleSizeLabel(
                  language: language,
                  list: select[0],
                  labels: labelsCallback,
                );
              } else {
                createMultipleSizeLabel(
                  language: language,
                  list: select[0],
                  labels: labelsCallback,
                );
              }
            } else {
              createNoSizeLabel(
                  language: language, list: select[0], labels: labelsCallback);
            }
          }
          break;
        default:
          break;
      }
    } else {
      switch (type) {
        case 101:
          logger.f('101');
          createMaterialLabel(
            language: language,
            list: select[0],
            labels: labelsCallback,
          );
          break;
        case 102:
          logger.f('102');
          createGroupDynamicLabel(
            language: language,
            list: select,
            labels: labelsCallback,
          );
          break;
        case 103:
          logger.f('103');
          createDynamicLabel(
            language: language,
            list: select[0],
            labels: labelsCallback,
          );
          break;
        default:
          break;
      }
    }
  }

  //单一物料无尺码标
  createNoSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(myanmarLabel(data, false));
    }
    labels.call(labelList);
  }

  Widget myanmarLabel(LabelInfo label, bool hasNotes) =>
      dynamicMyanmarLabel110xN(
        labelID: label.barCode ?? '',
        myanmarApprovalDocument: label.myanmarApprovalDocument ?? '',
        typeBody: label.factoryType ?? '',
        trackNo: label.trackNo ?? '',
        instructionNo: label.billNo ?? '',
        // materialList: [
        //   for (var m in label.items!)
        //     [m.materialNumber ?? '', m.specifications ?? '']
        // ],
        materialList: [],
        inBoxQty: label.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.meas ?? '',
        volume: label.volume ?? '',
        supplier: label.departName ?? '',
        manufactureDate: label.manufactureDate ?? '',
        hasNotes: hasNotes,
        notes: '',
      );

  //单一物料多尺码标
  createMultipleSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(myanmarSizeListLabel(data, false));
    }
    labels.call(labelList);
  }

  Widget myanmarSizeListLabel(LabelInfo label, bool hasNotes) =>
      dynamicMyanmarSizeListLabel110xN(
        labelID: label.barCode ?? '',
        myanmarApprovalDocument: label.myanmarApprovalDocument ?? '',
        typeBody: label.factoryType ?? '',
        trackNo: label.trackNo ?? '',
        materialList: createSizeList(
          label: label,
          sizeTitle: 'Size',
          totalTitle: 'Total',
        ),
        inBoxQty: label.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.meas ?? '',
        volume: label.volume ?? '',
        supplier: label.departName ?? '',
        manufactureDate: label.manufactureDate ?? '',
        hasNotes: hasNotes,
        notes: '',
      );

  Map<String, List> createSizeList({
    required LabelInfo label,
    required String sizeTitle,
    required String totalTitle,
  }) {
    var materials = <String, List>{};
    if (label.items!.any((v) => v.size?.isNotEmpty == true)) {
      var sizeList = <String>[];
      for (var label in label.items!) {
        if (!sizeList.contains(label.size)) {
          sizeList.add(label.size ?? '');
        }
      }
      sizeList.sort();
      materials[sizeTitle] = [...sizeList, totalTitle];
      groupBy(
        label.items!,
        (v) => v.billNo ?? '',
      ).forEach((k, labels) {
        var list = [];
        for (var size in sizeList) {
          try {
            list.add(labels
                .firstWhere((label) => label.size == size)
                .qty
                .toShowString());
          } on StateError catch (_) {
            list.add(' ');
          }
        }
        list.add(labels
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString());
        materials[k] = list;
      });
    }
    return materials;
  }

  //单一物料单尺码标
  createSingleSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(myanmarSizeLabel(data, false));
    }
    labels.call(labelList);
  }

  Widget myanmarSizeLabel(LabelInfo label, bool hasNotes) =>
      dynamicMyanmarSizeLabel110xN(
        labelID: label.barCode ?? '',
        myanmarApprovalDocument: label.myanmarApprovalDocument ?? '',
        typeBody: label.factoryType ?? '',
        trackNo: label.trackNo ?? '',
        instructionNo: label.billNo ?? '',
        materialCode: label.materialCode ?? '',
        size: label.items!.first.size ?? '',
        inBoxQty: label.items!.first.qty.toShowString(),
        customsDeclarationUnit: label.customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.meas ?? '',
        volume: label.volume ?? '',
        supplier: label.departName ?? '',
        manufactureDate: label.manufactureDate ?? '',
        hasNotes: hasNotes,
        notes: '',
      );

  //物料标
  createMaterialLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var languageInfo =
          data.materialOtherName!.firstWhere((v) => v.languageName == language);
      var labelTitle = Text(
        data.factoryType ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
      var labelSubTitle = Text(
        data.billNo ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
      var labelContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              '(${data.materialCode})${data.materialName}'
                  .allowWordTruncation(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                height: 1,
              ),
              maxLines: 3,
            ),
          ),
          if (languageInfo.languageCode != 'zh')
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GW:${data.grossWeight.toShowString()}KG',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'NW:${data.netWeight.toShowString()}KG',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          if (languageInfo.languageCode != 'zh')
            Text(
              'MEAS:${data.meas}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1,
              ),
            ),
        ],
      );
      var labelBottomLeft = Center(
        child: Text(
          languageInfo.pageNumber ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );

      var labelBottomRight = Column(
        children: [
          Expanded(
            child: Text(
              data.items?.isEmpty == true
                  ? '0'
                  : data.items!
                      .map((v) => v.qty ?? 0)
                      .reduce((a, b) => a.add(b))
                      .toShowString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              languageInfo.unitName ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

      labelList.add(fixedLabelTemplate75x45(
        qrCode: data.barCode ?? '',
        title: labelTitle,
        subTitle: labelSubTitle,
        content: labelContent,
        bottomLeft: labelBottomLeft,
        bottomRight: labelBottomRight,
      ));
    }
    labels.call(labelList);
  }

  //动态标
  createDynamicLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      //标签语言类型
      var languageInfo =
          data.materialOtherName!.firstWhere((v) => v.languageName == language);
      //标签指令列表
      var ins = groupBy(data.items ?? <LabelSizeInfo>[], (v) => v.billNo);
      //标签装货总数
      var total = data.items?.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));

      //表格列表
      Map<String, List<List<String>>> map = {};
      ins.forEach((k, v1) {
        map[k ?? ''] = [
          for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
        ];
      });

      //表格最大行数
      var groupMax = ins.length > 1 ? ins.length + 2 : ins.length + 1;

      //表格拆分后最大列数
      var maxArrange = 7;

      //表格拆分成列表
      var table = labelTableFormat(
        title: languageInfo.languageCode == 'zh' ? '尺码' : 'Size',
        total: ins.length > 1
            ? languageInfo.languageCode == 'zh'
                ? '合计'
                : 'Total'
            : null,
        list: map,
      );

      var labelTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          data.factoryType ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );

      var labelSubTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          languageInfo.languageCode == 'zh'
              ? '${data.billNo}'.allowWordTruncation()
              : '(${data.materialCode})${languageInfo.name}'
                  .allowWordTruncation(),
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );

      var labelHeader = Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: languageInfo.languageCode == 'zh'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${total.toShowString()}${languageInfo.unitName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                  Text(
                    '(${data.materialCode})${languageInfo.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'GW:${data.grossWeight.toShowString()}KG',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'NW:${data.netWeight.toShowString()}KG',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MEAS:${data.meas} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${total.toShowString()}${languageInfo.unitName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );

      var labelTable = Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < table.length; ++i) ...[
              Row(
                children: [
                  for (var j = 0; j < table[i].length; ++j)
                    expandedFrameText(
                      alignment: j == 0
                          ? Alignment.centerLeft
                          : i == 0 ||
                                  (table[i].isEmpty ? i - 1 : i) %
                                          (groupMax + 1) ==
                                      0
                              ? Alignment.center
                              : Alignment.centerRight,
                      flex: j == 0 ? 9 : 4,
                      isBold: true,
                      text: table[i][j],
                    ),
                  if (maxArrange - table[i].length > 0)
                    for (var j = 0; j < maxArrange - table[i].length; ++j)
                      Expanded(flex: 4, child: Container()),
                ],
              ),
              if (table[i].isEmpty) const SizedBox(height: 10)
            ]
          ],
        ),
      );
      var labelFooter = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: languageInfo.languageCode == 'zh'
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      languageInfo.pageNumber ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      languageInfo.deliveryDate ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          languageInfo.pageNumber ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          languageInfo.deliveryDate ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Made in China',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Gold Emperor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
      labelList.add(dynamicLabelTemplate75xN(
        qrCode: data.barCode ?? '',
        title: labelTitle,
        subTitle: labelSubTitle,
        header: labelHeader,
        table: labelTable,
        footer: labelFooter,
      ));
    }
    labels.call(labelList);
  }

  //固定单码标
  createFixedLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var languageInfo = data[0]
          .materialOtherName!
          .firstWhere((v) => v.languageName == language);
      var labelTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          data[0].factoryType ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );
      var labelSubTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          data[0].billNo ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );
      var labelContent = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Text(
                '(${data[0].materialCode})${languageInfo.name}'
                    .allowWordTruncation(),
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  height: 1,
                ),
                maxLines: 3,
              ),
            ),
            if (languageInfo.languageCode != 'zh')
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'GW:${data[0].grossWeight.toShowString()}KG',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'NW:${data[0].netWeight.toShowString()}KG',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            if (languageInfo.languageCode != 'zh')
              Text(
                'MEAS:${data[0].meas}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1,
                ),
              ),
          ],
        ),
      );
      var labelBottomLeft = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Center(
          child: Text(
            languageInfo.languageCode == 'zh'
                ? '${data[0].items?[0].size} #'
                : '${data[0].items?[0].qty.toShowString()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
      var labelBottomMiddle = Column(
        children: [
          Expanded(
            child: Text(
              languageInfo.pageNumber ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              languageInfo.languageCode == 'zh'
                  ? languageInfo.deliveryDate ?? ''
                  : 'Made in China',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

      var labelBottomRight = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Center(
          child: Text(
            languageInfo.languageCode == 'zh'
                ? languageInfo.unitName ?? ''
                : '${data[0].items?[0].size} #',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );

      labelList.add(fixedLabelTemplate75x45(
        qrCode: data[0].barCode ?? '',
        title: labelTitle,
        subTitle: labelSubTitle,
        content: labelContent,
        bottomLeft: labelBottomLeft,
        bottomMiddle: labelBottomMiddle,
        bottomRight: labelBottomRight,
      ));
    }
    labels.call(labelList);
  }

  //合并动态标签
  createGroupDynamicLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      //标签语言类型
      var languageInfo = data[0]
          .materialOtherName!
          .firstWhere((v) => v.languageName == language);
      var insList = <LabelSizeInfo>[];
      for (var item in data) {
        if (!item.items.isNullOrEmpty()) {
          insList.addAll(item.items!);
        }
      }
      //标签指令列表
      var ins = groupBy(insList, (v) => v.billNo);

      //标签装货总数
      var total = insList.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));

      //表格列表
      Map<String, List<List<String>>> map = {};
      ins.forEach((k, v1) {
        map[k ?? ''] = [
          for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
        ];
      });

      //表格最大行数
      var groupMax = ins.length > 1 ? ins.length + 2 : ins.length + 1;

      //表格拆分后最大列数
      var maxArrange = 7;

      //表格拆分成列表
      var table = labelTableFormat(
        title: languageInfo.languageCode == 'zh' ? '尺码' : 'Size',
        total: ins.length > 1
            ? languageInfo.languageCode == 'zh'
                ? '合计'
                : 'Total'
            : null,
        list: map,
      );

      var labelTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          data[0].factoryType ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );

      var labelSubTitle = Padding(
        padding: const EdgeInsets.only(
          left: 3,
          right: 3,
        ),
        child: Text(
          languageInfo.languageCode == 'zh'
              ? '${data[0].billNo}'.allowWordTruncation()
              : '(${data[0].materialCode})${languageInfo.name}'
                  .allowWordTruncation(),
          style: const TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );

      var labelHeader = Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: languageInfo.languageCode == 'zh'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${total.toShowString()}${languageInfo.unitName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                  Text(
                    '(${data[0].materialCode})${languageInfo.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'GW:${data[0].grossWeight.toShowString()}KG',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'NW:${data[0].netWeight.toShowString()}KG',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MEAS:${data[0].meas} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${total.toShowString()}${languageInfo.unitName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );

      var labelTable = Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < table.length; ++i) ...[
              Row(
                children: [
                  for (var j = 0; j < table[i].length; ++j)
                    expandedFrameText(
                      alignment: j == 0
                          ? Alignment.centerLeft
                          : i == 0 ||
                                  (table[i].isEmpty ? i - 1 : i) %
                                          (groupMax + 1) ==
                                      0
                              ? Alignment.center
                              : Alignment.centerRight,
                      flex: j == 0 ? 9 : 4,
                      isBold: true,
                      text: table[i][j],
                    ),
                  if (maxArrange - table[i].length > 0)
                    for (var j = 0; j < maxArrange - table[i].length; ++j)
                      Expanded(flex: 4, child: Container()),
                ],
              ),
              if (table[i].isEmpty) const SizedBox(height: 10)
            ]
          ],
        ),
      );
      var labelFooter = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: languageInfo.languageCode == 'zh'
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      languageInfo.pageNumber ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      languageInfo.deliveryDate ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          languageInfo.pageNumber ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          languageInfo.deliveryDate ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Made in China',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Gold Emperor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
      labelList.add(dynamicLabelTemplate75xN(
        qrCode: data[0].barCode ?? '',
        title: labelTitle,
        subTitle: labelSubTitle,
        header: labelHeader,
        table: labelTable,
        footer: labelFooter,
      ));
    }
    labels.call(labelList);
  }

  List<Widget> createSubItem({
    required List<LabelInfo> data,
    required Widget Function(
      String text1,
      String text2,
      String text3,
      int type,
    ) subItem,
  }) {
    var widgetList = <Widget>[
      subItem.call(
        'maintain_label_sub_item_instruction'.tr,
        'maintain_label_sub_item_size'.tr,
        'maintain_label_sub_item_packing_qty'.tr,
        1,
      )
    ];
    groupBy(data, (v) => v.items?[0].size).forEach((k, v) {
      for (var v2 in v) {
        widgetList.add(subItem.call(
          v2.items![0].billNo ?? 'maintain_label_sub_item_instruction_error'.tr,
          v2.items![0].size ?? '',
          v2.items![0].qty.toShowString(),
          2,
        ));
      }
      if (state.isSingleLabel) {
        var subtotal = 0.0;
        for (var v2 in v) {
          subtotal = subtotal.add(v2.items![0].qty ?? 0.0);
        }
        widgetList.add(subItem.call(
          '',
          k!,
          v
              .map((v2) => v2.items?[0].qty ?? 0)
              .reduce((a, b) => a.add(b))
              .toShowString(),
          3,
        ));
      }
    });
    return widgetList;
  }
}
