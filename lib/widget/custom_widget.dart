import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jd_flutter/route.dart';

import '../bean/http/response/worker_info.dart';
import '../utils.dart';
import '../web_api.dart';

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

///ios适配专用输入法
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

///文本输入框
class EditText extends StatelessWidget {
  const EditText({
    super.key,
    this.hint,
    this.initStr = '',
    this.hasFocus = false,
    this.controller,
    this.onChanged,
  });

  final String? initStr;
  final bool hasFocus;
  final String? hint;
  final Function(String v)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initStr);
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: TextField(
        controller: this.controller ?? controller,
        onChanged: (v) {
          onChanged?.call(v);
        },
        focusNode: fn,
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
            onPressed: () => (this.controller ?? controller).clear(),
          ),
        ),
      ),
    );
  }
}

///数字小数输入框输入框
class NumberDecimalEditText extends StatelessWidget {
  const NumberDecimalEditText({
    super.key,
    this.hasDecimal = true,
    this.max = double.infinity,
    this.initQty = 0.0,
    this.hint,
    this.hasFocus = false,
    required this.onChanged,
  });

  final String? hint;
  final bool hasDecimal;
  final double? max;
  final double? initQty;
  final bool hasFocus;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: initQty.toShowString());
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [
          hasDecimal
              ? FilteringTextInputFormatter.allow(RegExp("[0-9.]")) //数字包括小数
              : FilteringTextInputFormatter.digitsOnly,
        ],
        focusNode: fn,
        controller: controller,
        onChanged: (v) {
          if (v.toDoubleTry() > max!) {
            controller.text = max.toShowString();
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
            onChanged.call(max!);
          } else {
            onChanged.call(v.toDoubleTry());
          }
        },
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

///自定义输入框 根据工号查询员工
class WorkerCheck extends StatefulWidget {
  const WorkerCheck({super.key, required this.onChanged, this.hint});

  final Function(WorkerInfo?) onChanged;
  final String? hint;

  @override
  State<WorkerCheck> createState() => _WorkerCheckState();
}

class _WorkerCheckState extends State<WorkerCheck> {
  var controller = TextEditingController();
  var name = ''.obs;
  var error = ''.obs;

  getWorker({
    required String number,
    required Function(WorkerInfo) success,
    required Function(String) error,
  }) {
    httpGet(method: webApiGetWorkerInfo, params: {
      'EmpNumber': number,
      'DeptmentID': '',
    }).then((worker) {
      if (worker.resultCode == resultSuccess) {
        var jsonList = jsonDecode(worker.data);
        var list = <WorkerInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(WorkerInfo.fromJson(jsonList[i]));
        }
        success.call(list[0]);
      } else {
        error.call(worker.message ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Obx(() => TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: controller,
            onChanged: (s) {
              if (s.length >= 6) {
                getWorker(
                    number: s,
                    success: (worker) {
                      name.value = worker.empName ?? '';
                      error.value = '';
                      widget.onChanged.call(worker);
                    },
                    error: (s) {
                      name.value = '';
                      error.value = s;
                      widget.onChanged.call(null);
                    });
              } else {
                name.value = '';
                error.value = '';
              }
            },
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
              helperText: name.value,
              helperStyle: TextStyle(color: Colors.green.shade700),
              errorText: error.value.isNotEmpty ? error.value : null,
              hintText: widget.hint?.isEmpty == true ? '请输入员工工号' : widget.hint,
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => controller.clear(),
              ),
            ),
          )),
    );
  }
}

///数字小数输入框输入框
class NumberEditText extends StatelessWidget {
  const NumberEditText({
    super.key,
    this.hint,
    this.hasFocus = false,
    required this.onChanged,
    this.controller,
  });

  final bool hasFocus;
  final String? hint;
  final Function(String) onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    var c = TextEditingController();
    FocusNode? fn;
    if (hasFocus) {
      fn = FocusNode()..requestFocus();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: TextField(
        focusNode: fn,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: controller ?? c,
        onChanged: onChanged,
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
            onPressed: () => (controller ?? c).clear(),
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
        title: Text(title??getFunctionTitle()),
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
        title: Text(title??getFunctionTitle()),
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
showSnackBar({
  bool? isWarning = false,
  required String title,
  required String message,
}) {
  snackbarController = Get.snackbar(title, message,
      margin: const EdgeInsets.all(10),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isWarning == true
          ? Colors.redAccent.shade100
          : Colors.blueAccent.shade100,
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

enum Combination { left, middle, right, intact }

class CombinationButton extends StatelessWidget {
  final Combination? combination;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool? isEnabled;
  final String text;
  final Function() click;

  const CombinationButton({
    super.key,
    required this.text,
    required this.click,
    this.combination = Combination.intact,
    this.backgroundColor = Colors.blueAccent,
    this.foregroundColor = Colors.white,
    this.isEnabled = true,
  });

  EdgeInsets getPadding() {
    EdgeInsets padding;
    switch (combination) {
      case Combination.left:
        padding = const EdgeInsets.only(left: 4, top: 4, right: 1, bottom: 4);
        break;
      case Combination.middle:
        padding = const EdgeInsets.only(left: 1, top: 4, right: 1, bottom: 4);
        break;
      case Combination.right:
        padding = const EdgeInsets.only(left: 1, top: 4, right: 4, bottom: 4);
        break;
      default:
        padding = const EdgeInsets.all(4);
        break;
    }
    return padding;
  }

  BorderRadius getRadius() {
    BorderRadius borderRadius;
    switch (combination) {
      case Combination.left:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        );
        break;
      case Combination.middle:
        borderRadius = const BorderRadius.all(Radius.zero);
        break;
      case Combination.right:
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        );
        break;
      default:
        borderRadius = const BorderRadius.all(Radius.circular(25));
        break;
    }
    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getPadding(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: 8, right: 8),
          backgroundColor: isEnabled == true ? backgroundColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: getRadius(),
          ),
        ),
        onPressed: () {
          if (isEnabled == true) {
            click.call();
          }
        },
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled == true ? foregroundColor : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

class CheckBox extends StatefulWidget {
  final Function(bool isChecked) onChanged;
  final String name;
  final bool value;
  final bool? isEnabled;
  final bool? needSave;

  const CheckBox({
    super.key,
    required this.onChanged,
    required this.name,
    required this.value,
    this.isEnabled = true,
    this.needSave = true,
  });

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  var isChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.needSave == true) {
      var initialValue =
          spGet('${Get.currentRoute}/${widget.name}') ?? widget.value ?? false;
      if (isChecked != initialValue) {
        setState(() => isChecked = initialValue);
      }
    } else {
      isChecked = widget.value;
    }
  }

  _checked(bool checked) {
    if (widget.isEnabled == true) {
      isChecked = checked;
      if (widget.needSave == true) {
        spSave('${Get.currentRoute}/${widget.name}', isChecked);
      }
      widget.onChanged.call(isChecked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecked != widget.value) {
      isChecked = widget.value;
      if (widget.needSave == true) {
        spSave('${Get.currentRoute}/${widget.name}', isChecked);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTap: () => _checked(!isChecked),
        child: Row(
          children: [
            Checkbox(
              activeColor: widget.isEnabled == true ? Colors.blue : Colors.grey,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
              ),
              value: isChecked,
              onChanged: (v) => _checked(v!),
            ),
            Text(
              widget.name,
              style: TextStyle(
                color: widget.isEnabled == true ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpinnerController {
  var select = ''.obs;
  var selectIndex = 0;
  String? saveKey;
  var dataList = <String>[];
  final Function(int)? onChanged;
  final Function(int)? onSelected;

  SpinnerController({
    this.saveKey,
    required this.dataList,
    this.onChanged,
    this.onSelected,
  }) {
    selectIndex = getSave();
    select.value = dataList[selectIndex];
    onSelected?.call(selectIndex);
  }

  int getSave() {
    var select = selectIndex;
    if (saveKey != null && saveKey!.isNotEmpty) {
      var save = spGet(saveKey!);
      if (save != null && save.isNotEmpty) {
        var index = dataList.indexOf(save);
        if (index != -1) select = index;
      }
    }
    return select;
  }

  changeSelected(String? value) {
    if (value != null && value.isNotEmpty) {
      select.value = value;
      var index = dataList.indexOf(value);
      if (index != -1) {
        selectIndex = index;
        spSave(saveKey!, value);
      }
      onChanged?.call(selectIndex);
    }
  }
}

class Spinner extends StatelessWidget {
  final SpinnerController controller;

  const Spinner({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Obx(() => DropdownButton<String>(
            isExpanded: true,
            value: controller.select.value,
            underline: Container(height: 0),
            onChanged: (String? value) => controller.changeSelected(value),
            items: controller.dataList
                .map<DropdownMenuItem<String>>((String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)))
                .toList(),
          )),
    );
  }
}

class SwitchButton extends StatefulWidget {
  final Function(bool isChecked) onChanged;
  final String name;
  final bool? value;
  final bool? isEnabled;
  final bool? needSave;

  const SwitchButton({
    super.key,
    required this.onChanged,
    required this.name,
    this.value,
    this.isEnabled = true,
    this.needSave = true,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  var isChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      if (widget.needSave == true) {
        var initialValue = spGet('${Get.currentRoute}/${widget.name}') ??
            widget.value ??
            false;
        if (isChecked != initialValue) {
          isChecked = initialValue;
        }
      }
    } else {
      isChecked = widget.value!;
    }
  }

  _select(bool checked) {
    if (widget.isEnabled == true && isChecked != checked) {
      setState(() {
        isChecked = checked;
        widget.onChanged.call(isChecked);
        if (widget.value == null && widget.needSave == true) {
          spSave('${Get.currentRoute}/${widget.name}', isChecked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.name,
            style: const TextStyle(color: Colors.black),
          ),
          Switch(
            thumbIcon: MaterialStateProperty.resolveWith<Icon>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return const Icon(Icons.check);
                }
                return const Icon(Icons.close);
              },
            ),
            value: isChecked,
            onChanged: _select,
          ),
        ],
      ),
    );
  }
}

expandedTextSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
  int flex = 1,
}) {
  return Expanded(
      flex: flex,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: hint,
              style: TextStyle(fontWeight: FontWeight.bold, color: hintColor),
            ),
            TextSpan(
              text: text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
}

textSpan({
  required String hint,
  Color hintColor = Colors.black,
  required String text,
  Color textColor = Colors.blueAccent,
}) {
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: hint,
          style: TextStyle(fontWeight: FontWeight.bold, color: hintColor),
        ),
        TextSpan(
          text: text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
