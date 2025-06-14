import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init_controller.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

//app 背景渐变色
backgroundColor() => BoxDecoration(
      gradient: LinearGradient(
        colors: isTestUrl()
            ? [
                Colors.green,
                Colors.blue.shade300,
              ]
            : [
                const Color.fromARGB(0xff, 0xe4, 0xe8, 0xda),
                const Color.fromARGB(0xff, 0xba, 0xe9, 0xed)
              ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    );

//页面简单框架
pageBody({
  String? title,
  List<Widget>? actions,
  String popTitle = '',
  required Widget body,
}) {
  return Container(
    decoration: backgroundColor(),
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title ?? getFunctionTitle()),
        actions: [
          ...?actions,
        ],
      ),
      body: popTitle.isNotEmpty
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) exitDialog(content: popTitle);
              },
              child: body,
            )
          : body,
    ),
  );
}

//页面简单框架 底部弹出Popup
pageBodyWithBottomSheet({
  String? title,
  List<Widget>? actions,
  bool? isShow,
  required List<Widget> bottomSheet,
  required Function() query,
  String popTitle = '',
  required Widget body,
}) {
  return Container(
    decoration: backgroundColor(),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title ?? getFunctionTitle()),
        actions: [
          ...?actions,
          Builder(
            //不加builder会导致openDrawer崩溃
            builder: (context) => IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSheet(
                  context: context,
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      ...bottomSheet,
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              query.call();
                            },
                            child: Text(
                              'page_title_with_drawer_query'.tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  scrollControlled: true,
                );
              },
            ),
          )
        ],
      ),
      body: popTitle.isNotEmpty
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) exitDialog(content: popTitle);
              },
              child: body,
            )
          : body,
    ),
  );
}

//页面简单框架 右侧弹出Drawer
pageBodyWithDrawer({
  String? title,
  List<Widget>? actions,
  required List<Widget> queryWidgets,
  required Function() query,
  String popTitle = '',
  required Widget body,
}) {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  return Container(
    decoration: backgroundColor(),
    child: Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title ?? getFunctionTitle()),
        actions: [
          ...?actions,
          Builder(
            //不加builder会导致openDrawer崩溃
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
        key: GlobalKey(),
        child: ListView(children: [
          const SizedBox(height: 30),
          ...queryWidgets,
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  scaffoldKey.currentState?.closeEndDrawer();
                  query.call();
                },
                child: Text(
                  'page_title_with_drawer_query'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
      body: popTitle.isNotEmpty
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (scaffoldKey.currentState?.isEndDrawerOpen == true) {
                  scaffoldKey.currentState?.closeEndDrawer();
                } else {
                  if (!didPop) exitDialog(content: popTitle);
                }
              },
              child: body,
            )
          : body,
    ),
  );
}

//照片选择器
takePhoto({required Function(File) callback, String? title}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text(
        title ?? 'home_user_setting_avatar_photo_sheet_title'.tr,
      ),
      message: Text('take_photo_sheet_message'.tr),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            _takePhoto(false, callback);
          },
          child: Text('take_photo_photo_sheet_take_photo'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            _takePhoto(true, callback);
          },
          child: Text('take_photo_photo_sheet_select_photo'.tr),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Get.back(),
        child: Text(
          'dialog_default_cancel'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    ),
  );
}

//获取照片
_takePhoto(bool isGallery, Function(File) callback) async {
  //获取照片
  var xFile = await ImagePicker().pickImage(
    imageQuality: 75,
    maxWidth: 700,
    maxHeight: 700,
    source: isGallery ? ImageSource.gallery : ImageSource.camera,
  );
  var cFile = await ImageCropper().cropImage(
    sourcePath: xFile!.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    // aspectRatioPresets: [CropAspectRatioPreset.square],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'cropper_title'.tr,
        toolbarColor: Colors.blueAccent,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'cropper_title'.tr,
        cancelButtonTitle: 'cropper_cancel'.tr,
        doneButtonTitle: 'cropper_confirm'.tr,
        aspectRatioPickerButtonHidden: true,
        resetAspectRatioEnabled: false,
        aspectRatioLockEnabled: true,
      ),
      WebUiSettings(context: Get.overlayContext!),
    ],
  );
  if (cFile != null) callback.call(File(cFile.path));
}

//显示SnackBar
showSnackBar({
  bool? isWarning,
  String? title,
  required String message,
}) {
  isWarning ??= false;
  title ??= isWarning
      ? 'snack_bar_default_wrong'.tr
      : 'dialog_default_title_information'.tr;
  if (Get.isSnackbarOpen) {
    snackbarController?.close(withAnimations: false);
  }
  snackbarController = Get.snackbar(
    title,
    message,
    margin: const EdgeInsets.all(10),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isWarning == true
        ? Colors.redAccent.shade100
        : Colors.greenAccent.shade100,
    colorText: isWarning == true ? Colors.white : Colors.blue.shade900,
    snackbarStatus: (state) {
      snackbarStatus = state;
    },
  );
}

//显示SnackBar
showScanTips({
  String tips = '+1',
  Color color = Colors.blueAccent,
  Duration duration = const Duration(milliseconds: 300),
}) {
  if (Get.isSnackbarOpen) {
    snackbarController?.close(withAnimations: false);
  }
  snackbarController = Get.snackbar(
    '',
    '',
    messageText: Center(
      child: AutoSizeText(
        tips,
        maxLines: 1,
        minFontSize: 150,
        maxFontSize: 200,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
    duration: duration,
    // margin: const EdgeInsets.all(10),
    overlayBlur: 5,
    barBlur: 0,
    overlayColor: Colors.transparent,
    reverseAnimationCurve: Curves.easeInOut,
    backgroundColor: Colors.transparent,
  );
}

//选择器
Widget getCupertinoPicker({
  required List<Widget> items,
  required FixedExtentScrollController controller,
}) {
  return CupertinoPicker(
    scrollController: controller,
    diameterRatio: 1.5,
    magnification: 1.2,
    squeeze: 1.2,
    useMagnifier: true,
    itemExtent: 32,
    onSelectedItemChanged: (value) {},
    children: items,
  );
}

//选择器
Widget getLinkCupertinoPicker({
  required List<String> groupItems,
  required List<List<String>> subItems,
  required FixedExtentScrollController groupController,
  required FixedExtentScrollController subController,
}) {
  var subIndex = 0.obs;
  return Obx(() => Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: groupController,
              onSelectedItemChanged: (value) {
                subIndex.value = value;
                subController.jumpToItem(0);
              },
              itemExtent: 22,
              squeeze: 1.2,
              children: groupItems.map((data) => Text(data)).toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: subController,
              onSelectedItemChanged: (value) {},
              itemExtent: 22,
              squeeze: 1.2,
              children:
                  subItems[subIndex.value].map((data) => Text(data)).toList(),
            ),
          ),
        ],
      ));
}

//popup工具
showPopup(Widget widget, {double? height}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) {
      return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: height ?? 260,
            color: Colors.grey[200],
            child: widget,
          ));
    },
  );
}

//底部弹出 sheet
Future<T?> showSheet<T>({
  required BuildContext context,
  required Widget body,
  bool scrollControlled = true,
  bool isDismissible = true,
  Color bodyColor = Colors.white,
  EdgeInsets? bodyPadding,
  BorderRadius? borderRadius,
}) {
  const radius = Radius.circular(16);
  borderRadius ??= const BorderRadius.only(topLeft: radius, topRight: radius);
  bodyPadding ??= const EdgeInsets.all(10);
  return showModalBottomSheet(
    isDismissible: isDismissible,
    context: context,
    elevation: 0,
    backgroundColor: bodyColor,
    shape: RoundedRectangleBorder(borderRadius: borderRadius),
    barrierColor: Colors.black.withValues(alpha: 0.25),
    constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.top),
    isScrollControlled: scrollControlled,
    builder: (ctx) => SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: bodyPadding!.left,
          top: bodyPadding.top,
          right: bodyPadding.right,
          bottom: bodyPadding.bottom + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: body,
      ),
    ),
  );
}

//带占比带文本提示的文本
expandedTextSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  double fontSize = 14,
  bool isBold = true,
  int maxLines = 1,
  int flex = 1,
}) {
  return Expanded(
      flex: flex,
      child: Text.rich(
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: [
            TextSpan(
              text: hint,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: hintColor),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ],
        ),
      ));
}

//带文本提示带文本
textSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  double fontSize = 14,
  bool isBold = true,
  bool isSpacing = false,
  int maxLines = 1,
}) {
  return Text.rich(
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    TextSpan(
      children: [
        TextSpan(
          text: isSpacing? '  $hint' :hint,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: hintColor,
          ),
        ),
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

//进度条、百分比
percentIndicator({
  required double max,
  required double value,
  double? height,
  Color? color,
  Color? backgroundColor,
  Color? textColor,
}) {
  var percent = (value.div(max).toStringAsFixed(3)).toDoubleTry();
  return Stack(
    children: [
      Center(
        child: LinearProgressIndicator(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          value: percent,
          minHeight: height ?? 20,
          backgroundColor: backgroundColor ?? Colors.grey.shade300,
          color: color ?? Colors.green.shade400,
        ),
      ),
      Center(
        child: Text(
          '${percent.mul(100).toShowString()}%',
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

//进度条、带文本
progressIndicator({
  required double max,
  required double value,
  double? height,
  Color? color,
  Color? backgroundColor,
  Color? textColor,
}) {
  var percent = 0.0;
  if (value != 0 || max != 0) {
    percent = (value.div(max).toStringAsFixed(3)).toDoubleTry();
  }

  return Stack(
    children: [
      Center(
        child: LinearProgressIndicator(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          value: percent,
          minHeight: height ?? 20,
          backgroundColor: backgroundColor ?? Colors.grey.shade300,
          color: color ?? Colors.green.shade400,
        ),
      ),
      Center(
        child: Text(
          '${value.toShowString()}/${max.toShowString()}',
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

//带框、带点击事件带文本
expandedFrameText({
  Function? click,
  Color? borderColor,
  Color? backgroundColor,
  Color? textColor,
  int? flex,
  EdgeInsetsGeometry? padding,
  AlignmentGeometry? alignment,
  bool isBold = false,
  required String text,
  int? maxLines = 1,
}) {
  var widget = Container(
    height: (maxLines! * 35).toDouble(),
    padding: padding ?? const EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(color: borderColor ?? Colors.grey),
      color: backgroundColor ?? Colors.transparent,
    ),
    alignment: alignment ?? Alignment.centerLeft,
    child: Text(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text,
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
        leading: 0.5,
      ),
      style: TextStyle(
        color: textColor ?? Colors.black87,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
  return Expanded(
    flex: flex ?? 1,
    child: text.isEmpty
        ? Container(
            height: (maxLines * 35).toDouble(),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.grey),
              color: backgroundColor ?? Colors.transparent,
            ),
          )
        : click == null
            ? widget
            : GestureDetector(
                onTap: () => click.call(),
                child: widget,
              ),
  );
}

//带框、带点击事件带文本
frameText({
  Function? click,
  Color? borderColor,
  Color? backgroundColor,
  Color? textColor,
  EdgeInsetsGeometry? padding,
  AlignmentGeometry? alignment,
  bool isBold = false,
  required String text,
  int? maxLines = 1,
}) {
  var widget = Container(
    height: (maxLines! * 35).toDouble(),
    padding: padding ?? const EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(color: borderColor ?? Colors.grey),
      color: backgroundColor ?? Colors.transparent,
    ),
    alignment: alignment ?? Alignment.centerLeft,
    child: Text(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text,
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
        leading: 0.5,
      ),
      style: TextStyle(
        color: textColor ?? Colors.black87,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
  return text.isEmpty
      ? Container(
          height: (maxLines * 35).toDouble(),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.grey),
            color: backgroundColor ?? Colors.transparent,
          ),
        )
      : click == null
          ? widget
          : GestureDetector(
              onTap: () => click.call(),
              child: widget,
            );
}

//固定宽高1比1的头像
avatarPhoto(String? url) {
  return AspectRatio(
    aspectRatio: 1 / 1,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: url == null
          ? Image.asset(
              'assets/images/ic_logo.png',
              color: Colors.blue,
            )
          : Image.network(
              url,
              fit: BoxFit.fill,
              errorBuilder: (ctx, err, stackTrace) => Image.asset(
                'assets/images/ic_logo.png',
                color: Colors.blue,
              ),
            ),
    ),
  );
}


//滚动选择器
selectView({
  required List<dynamic> list,
  FixedExtentScrollController? controller,
  String errorMsg = '',
  String hint = '',
  Function(int)? select,
}) {
  var weights = [
    Text(
      hint,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    Expanded(
        child: CupertinoPicker(
      scrollController: controller,
      magnification: 1.2,
      useMagnifier: true,
      itemExtent: 26,
      onSelectedItemChanged: (v) => select?.call(v),
      children: list
          .map((v) => AutoSizeText(
                v.toString(),
                maxLines: 1,
                minFontSize: 8,
                maxFontSize: 16,
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ))
          .toList(),
    ))
  ];

  return Container(
    height: list.length > 1
        ? 120
        : errorMsg.length > 15
            ? 50
            : 35,
    width: double.infinity,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(list.length > 1 ? 10 : 25),
    ),
    child: list.length > 1
        ? GetPlatform.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: weights)
            : Row(children: weights)
        : list.isEmpty
            ? Row(
                children: [
                  Expanded(
                      child: AutoSizeText(
                    errorMsg,
                    style: const TextStyle(color: Colors.red),
                    maxLines: 2,
                    minFontSize: 12,
                    maxFontSize: 16,
                  ))
                ],
              )
            : Row(children: [textSpan(hint: hint, text: list[0].toString())]),
  );
}

//是否深色
bool isDeepColor(Color color) {
  if (color == Colors.transparent) {
    return false;
  }
  var grayscale = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
  //灰阶值小于到30%认定为深色。
  return grayscale < 0.3;
}

//柱状图进度条
Widget ratioBarChart({
  double width = double.infinity,
  required List<List<dynamic>> ratioList,
}) {
  var list = <Widget>[];
  var radius = const Radius.circular(13);
  for (var i = 0; i < ratioList.length; ++i) {
    var percent = (ratioList[i][0] as double);
    var colorName = (ratioList[i][1] as String);
    var color = colorName.getColorByDescription();
    var text = Center(
        child: Text(
      '${percent.toShowString()}% ${colorName.isEmpty ? '无色' : colorName}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isDeepColor(color) ? Colors.white : Colors.black,
      ),
    ));
    list.add(
      Expanded(
        flex: percent.toInt(),
        child: i == 0
            ? Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: radius,
                    bottomLeft: radius,
                  ),
                  color: color,
                ),
                child: text,
              )
            : i == ratioList.length - 1
                ? Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: radius,
                        bottomRight: radius,
                      ),
                      color: color,
                    ),
                    child: text,
                  )
                : Container(height: 50, color: color, child: text),
      ),
    );
  }

  return Container(
    height: 50,
    width: width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.blueAccent,
        width: 2,
      ),
    ),
    child: Row(children: list),
  );
}

List<Widget> createA4Paper(PickingMaterialOrderPrintInfo data) {
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
    required Color backgroundColor,
    required String? materialCode,
    required String? materialName,
    required String? colorSystem,
    required String? location,
    required String? unit,
    required String? contractOweQty,
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
            paperTableRow(3, materialCode ?? '', CrossAxisAlignment.start),
            paperTableRow(11, materialName ?? '', CrossAxisAlignment.start),
            paperTableRow(3, colorSystem ?? '', CrossAxisAlignment.start),
            paperTableRow(3, location ?? '', CrossAxisAlignment.start),
            paperTableRow(1, unit ?? '', CrossAxisAlignment.center),
            paperTableRow(2, contractOweQty ?? '', CrossAxisAlignment.end),
            paperTableRow(2, shouldInventoryQty ?? '', CrossAxisAlignment.end),
            paperTableRow(2, actualInventoryQty ?? '', CrossAxisAlignment.end),
            paperTableRow(2, picking ?? '', CrossAxisAlignment.end),
            paperTableRow(2, actual ?? '', CrossAxisAlignment.end),
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
                    '领料单号：$orderNumber',
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
                    '供应商：$supplierName',
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

  //根据仓库进行物料分类
  var warehouseList = <List<PickingMaterialOrderPrintMaterialInfo>>[];
  groupBy(data.materialList!, (v) => v.warehouseNumber ?? '').forEach((k, v) {
    warehouseList.add(v);
  });

  //根据物料组进行表格行控件的创建
  for (var item1 in warehouseList) {
    //添加仓库行
    widgetList.add([
      30,
      Container(
        height: 29,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '仓库：${item1[0].warehouseName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            )
          ],
        ),
      )
    ]);
    //添加表头行
    widgetList.add([
      30,
      paperTableLine(
        backgroundColor: Colors.grey.shade400,
        materialCode: '物料编号',
        materialName: '物料描述',
        colorSystem: '色系',
        location: '库位',
        unit: '单位',
        contractOweQty: '合同欠数',
        shouldInventoryQty: '应备货数',
        actualInventoryQty: '实备货数',
        picking: '应领料数',
        actual: '实领料数',
      )
    ]);
    //添加物料行
    for (var i = 0; i < item1.length; ++i) {
      widgetList.add([
        30,
        paperTableLine(
          backgroundColor: i % 2 == 0 ? Colors.white : Colors.grey.shade200,
          materialCode: item1[i].materialCode,
          materialName: item1[i].materialName,
          colorSystem: item1[i].colorInfo,
          location: item1[i].location,
          unit: item1[i].basicUnit,
          contractOweQty: item1[i].contractOweQty.toShowString(),
          shouldInventoryQty: item1[i].shouldInventoryQty.toShowString(),
          actualInventoryQty: '',
          picking: item1[i].totalInventoryQty.toShowString(),
          actual: '',
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
