import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

//app 背景渐变色
var backgroundColor = const BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromARGB(0xff, 0xe4, 0xe8, 0xda),
      Color.fromARGB(0xff, 0xba, 0xe9, 0xed)
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
    decoration: backgroundColor,
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
      body: PopScope(
        canPop: popTitle.isEmpty ? true : false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Get.dialog(AlertDialog(
              title: Text('dialog_default_exit_title'.tr),
              content: Text(
                popTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(closeOverlays: true),
                  child: Text('dialog_default_confirm'.tr),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'dialog_default_cancel'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ));
          }
        },
        child: body,
      ),
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
    decoration: backgroundColor,
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
      body: PopScope(
        canPop: popTitle.isEmpty ? true : false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Get.dialog(AlertDialog(
              title: Text('dialog_default_exit_title'.tr),
              content: Text(
                popTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(closeOverlays: true),
                  child: Text('dialog_default_confirm'.tr),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'dialog_default_cancel'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ));
          }
        },
        child: body,
      ),
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
    decoration: backgroundColor,
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
      body: PopScope(
        canPop: popTitle.isEmpty ? true : false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Get.dialog(AlertDialog(
              title: Text('dialog_default_exit_title'.tr),
              content: Text(
                popTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(closeOverlays: true),
                  child: Text('dialog_default_confirm'.tr),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'dialog_default_cancel'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ));
          }
        },
        child: body,
      ),
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
  Duration duration = const Duration(milliseconds: 500),
}) {
  Get.snackbar(
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
getCupertinoPicker(List<Widget> items, FixedExtentScrollController controller) {
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
showSheet<T>({
  required BuildContext context,
  required Widget body,
  bool scrollControlled = true,
  Color bodyColor = Colors.white,
  EdgeInsets? bodyPadding,
  BorderRadius? borderRadius,
}) {
  const radius = Radius.circular(16);
  borderRadius ??= const BorderRadius.only(topLeft: radius, topRight: radius);
  bodyPadding ??= const EdgeInsets.all(10);
  return showModalBottomSheet(
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
  int maxLines = 1,
}) {
  return Text.rich(
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    TextSpan(
      children: [
        TextSpan(
          text: hint,
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
  return Expanded(
    flex: flex ?? 1,
    child: text.isEmpty
        ? Container(
            height: (maxLines! * 35).toDouble(),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.grey),
              color: backgroundColor ?? Colors.transparent,
            ),
          )
        : GestureDetector(
            onTap: () => click?.call(),
            child: Container(
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
            ),
          ),
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

surplusMaterialLabelTemplate({
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

//标准格式标签模版
//75*45大小
fixedLabelTemplate({
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

//动态格式标签模版
//45宽，高度由内容决定
dynamicLabelTemplate({
  required String qrCode,
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
    width: 75 * 5.5,
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
              height: 19 * 5.5,
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

//标签表格格式化
List<List<String>> labelTableFormat({
  required String title,
  String? total,
  required Map<String, List<List<String>>> list,
}) {
  if (list.isEmpty) return [];

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
