import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../utils.dart';

///数字输入框 ios端添加 done 按钮
class NumberTextField extends StatefulWidget {
  final TextEditingController numberController;
  final InputDecoration decoration;
  final TextStyle textStyle;
  final int maxLength;

  const NumberTextField(
      {super.key,
      required this.numberController,
      required this.maxLength,
      required this.textStyle,
      required this.decoration});

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  OverlayEntry? _overlayEntry;
  final FocusNode _numberFocusNode = FocusNode();

  Widget doneButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      right: 0.0,
      left: 0.0,
      child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: CupertinoButton(
                padding:
                    const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Text('key_board_done'.tr,
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          )),
    );
  }

  ///显示done键
  showOverlay() {
    if (_overlayEntry != null) return;
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => doneButton(context));
    overlayState.insert(_overlayEntry!);
  }

  ///移除 done 键
  removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void initState() {
    super.initState();

    if (GetPlatform.isIOS) {
      //ios 端添加监听
      _numberFocusNode.addListener(() {
        if (_numberFocusNode.hasFocus) {
          showOverlay();
        } else {
          removeOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      controller: widget.numberController,
      focusNode: _numberFocusNode,
      decoration: widget.decoration,
      maxLength: widget.maxLength,
    );
  }
}

class EditText extends StatelessWidget {
  const EditText({super.key, required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            left: 10,
            right: 10,
          ),
          filled: true,
          fillColor: Colors.grey[300],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => controller.clear(),
          ),
        ),
      ),
    );
  }
}

class TextContainer extends StatelessWidget {
  const TextContainer({
    super.key,
    required this.text,
    this.borderColor,
    this.backgroundColor,
    this.width,
    this.height,
  });

  final Widget text;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey),
        color: backgroundColor ?? Colors.transparent,
      ),
      alignment: Alignment.centerLeft,
      child: text,
    );
  }
}
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

pageBody({
  required String title,
  List<Widget>? actions,
  required Widget? body,
}) {
  return Container(
    decoration: backgroundColor,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
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
  required String title,
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
        title: Text(title),
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
                      const SizedBox(height: 30),
                      ...bottomSheet,
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
  required String title,
  List<Widget>? actions,
  required List<Widget> children,
  required Function query,
  required Widget? body,
}) {
  return Container(
    decoration: backgroundColor,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
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
        child: ListView(children: [
          const SizedBox(height: 30),
          ...children,
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
          child: Text('dialog_default_cancel'.tr),
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
    aspectRatioPresets: [CropAspectRatioPreset.square],
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
showSnackBar({required String title, required String message}) {
  snackbarController = Get.snackbar(title, message,
      margin: const EdgeInsets.all(10),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white, snackbarStatus: (state) {
        if (state == SnackbarStatus.CLOSED) snackbarController = null;
      });
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
      bool scrollControlled = false,
      Color bodyColor = Colors.white,
      EdgeInsets? bodyPadding,
      BorderRadius? borderRadius,
    }) {
  const radius = Radius.circular(16);
  borderRadius ??= const BorderRadius.only(topLeft: radius, topRight: radius);
  bodyPadding ??= const EdgeInsets.all(20);
  return showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: bodyColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      barrierColor: Colors.black.withOpacity(0.25),
      // A处
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top),
      isScrollControlled: scrollControlled,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: bodyPadding!.left,
          top: bodyPadding.top,
          right: bodyPadding.right,
          // B处
          bottom:
          bodyPadding.bottom + MediaQuery.of(ctx).viewPadding.bottom,
        ),
        child: body,
      ));
}

///常用格式的按钮
button(
    String text,
    Function() click, {
      Color? backgroundColor,
      Color? textColor,
    }) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: click,
        child: Text(text, style: TextStyle(color: textColor ?? Colors.white)),
      ),
    ),
  );
}
