import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';


///app 背景渐变色
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

///页面简单框架
pageBody({
  String? title,
  List<Widget>? actions,
  required Widget? body,
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
        ],
      ),
      body: body,
    ),
  );
}

///页面简单框架 底部弹出Popup
pageBodyWithBottomSheet({
  String? title,
  List<Widget>? actions,
  required List<Widget> bottomSheet,
  required Function query,
  required Widget? body,
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
                  context,
                  Column(
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
      body: body,
    ),
  );
}

///页面简单框架 右侧弹出Drawer
pageBodyWithDrawer({
  String? title,
  List<Widget>? actions,
  required List<Widget> queryWidgets,
  required Function query,
  required Widget? body,
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
      body: body,
    ),
  );
}

///照片选择器
takePhoto(Function(File) callback, {String? title}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: title != null
          ? Text('home_user_setting_avatar_photo_sheet_title'.tr)
          : null,
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
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Get.back(),
          child: Text(
            'dialog_default_cancel'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

///获取照片
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

///显示SnackBar
showSnackBar({
  bool? isWarning = false,
  required String title,
  required String message,
}) {
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

///显示SnackBar
showScanTips() {
  Get.snackbar(
    '',
    '',
    messageText: const Center(
      child: Text(
        '+1',
        style: TextStyle(
          fontSize: 200,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    ),
    duration: const Duration(milliseconds: 500),
    margin: const EdgeInsets.all(10),
    overlayBlur: 5,
    barBlur: 0,
    overlayColor: Colors.transparent,
    reverseAnimationCurve: Curves.bounceOut,
    backgroundColor: Colors.transparent,
  );
}

///选择器
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

///popup工具
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

///底部弹出 sheet
Future<T?> showSheet<T>(
  BuildContext context,
  Widget body, {
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
    barrierColor: Colors.black.withOpacity(0.25),
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

///带占比带文本提示的文本
expandedTextSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  double fontSize = 14,
  bool isBold = true,
  int flex = 1,
}) {
  return Expanded(
      flex: flex,
      child: Text.rich(
        maxLines: 1,
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

///带文本提示带文本
textSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  double fontSize = 14,
  bool isBold = true,
}) {
  return Text.rich(
    maxLines: 1,
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

///进度条、百分比
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

///进度条、带文本
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

///带框、带点击事件带文本
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
}) {
  return Expanded(
    flex: flex ?? 1,
    child: GestureDetector(
      onTap: () => click?.call(),
      child: Container(
        padding: padding ?? const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.grey),
          color: backgroundColor ?? Colors.transparent,
        ),
        alignment: alignment ?? Alignment.centerLeft,
        child: Text(
          maxLines: 1,
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

///固定宽高1比1的头像
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

///标准格式标签模版
///75*45大小
labelTemplate({
  required String qrCode,
  Widget? title,
  Widget? subTitle,
  Widget? content,
  Widget? subContent,
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
  var contentWidget = Container(
    decoration: BoxDecoration(
      border: Border(bottom: bs),
    ),
    child: content ?? const Text(''),
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
          child: bottomLeft ?? const Text(''),
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          child: bottomMiddle ?? const Text(''),
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: bs),
          ),
          child: bottomRight ?? const Text(''),
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

selectView({
  required List<dynamic> list,
  required FixedExtentScrollController controller,
  required String errorMsg,
  required String hint,
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
