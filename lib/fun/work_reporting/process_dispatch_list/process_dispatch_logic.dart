import 'dart:ffi';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_detail_info.dart';
import 'package:jd_flutter/bean/http/response/process_work_card_list_info.dart';
import 'package:jd_flutter/fun/work_reporting/process_dispatch_list/process_dispatch_detail_view.dart';
import 'package:jd_flutter/fun/work_reporting/process_dispatch_list/process_dispatch_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ProcessDispatchLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ProcessDispatchState state = ProcessDispatchState();

  //tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);

  var textNumber = TextEditingController(); //异常数量

  //工序派工单列表
  void getWorkCardList({
    required String workTicket,
    required String date,
    required String empNumber,
  }) {
    httpGet(
      loading: 'process_dispatch_get_list'.tr,
      method: webApiGetProcessWorkCardList,
      params: {
        'WorkTicketNumber': workTicket,
        'Date': date,
        'EmpNumber': empNumber,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ProcessWorkCardListInfo>[
          for (var i = 0; i < response.data.length; ++i)
            ProcessWorkCardListInfo.fromJson(response.data[i])
        ];
        state.dataList.value = list;
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //选择数据
  void selectData(int position) {
    state.dataList[position].select = !state.dataList[position].select;
    state.dataList.refresh();
  }

  //只允许选择一条数据
  bool selectOnlyOne() {
    var selectNum = state.dataList.where((data) => data.select == true).length;

    if (selectNum == 1) {
      return true;
    } else if (selectNum == 0) {
      showSnackBar(message: 'process_dispatch_please_select_data'.tr);
      return false;
    } else {
      showSnackBar(message: 'process_dispatch_only_select_one'.tr);
      return false;
    }
  }

  //选择多条同派工单数据
  bool selectSame() {
    var selectNum = state.dataList.where((data) => data.select == true).length;

    if (selectNum == 1) {
      showSnackBar(message: 'process_dispatch_select_more'.tr);
      return false;
    } else if (selectNum == 0) {
      showSnackBar(message: 'process_dispatch_please_select_data'.tr);
      return false;
    } else {
      if (state.dataList.where((dat) => dat.select == true).toList().every(
          (data) =>
              data.interID ==
              state.dataList
                  .firstWhere((data2) => data2.select == true)
                  .interID)) {
        return true;
      } else {
        showSnackBar(message: 'process_dispatch_select_same'.tr);
        return false;
      }
    }
  }

  //拆分部件
  void splitPart({
    required Function(String) success,
  }) {
    var havePart = false;

    for (var v in state.dataList) {
      if (v.select) {
        if (v.partIDs!.length <= 1) {
          havePart = false;
        } else {
          havePart = true;
        }
      }
    }

    if (havePart) {
      httpPost(
        method: webApiPartsDisassembly,
        loading: 'process_dispatch_splitting_part'.tr,
        body: {
          'InterID':
              state.dataList.firstWhere((data) => data.select == true).interID,
          'PartIDs':
              state.dataList.firstWhere((data) => data.select == true).partIDs,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(response.message ?? 'process_dispatch_success_split'.tr);
        } else {
          errorDialog(
              content: response.message ?? 'process_dispatch_fail_split'.tr);
        }
      });
    } else {
      showSnackBar(message: 'process_dispatch_no_part_split'.tr);
    }
  }

  //合并部件
  void mergePart({
    required Function(String) success,
  }) {
    var list = [];
    for (var data in state.dataList.where((data) => data.select == true)) {
      data.partIDs?.forEach((v) {
        list.add(v);
      });
    }

    httpPost(
      method: webApiPartsMerging,
      loading: 'process_dispatch_merge_part'.tr,
      body: {
        'InterID':
            state.dataList.firstWhere((data) => data.select == true).interID,
        'PartIDs': list,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'process_dispatch_merge_success'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'process_dispatch_merge_fail'.tr);
      }
    });
  }

  //获取详情
  void getDetail({
    required bool toPage,
  }) {

    var idList = <int>[];
    var cardList = <String>[];
    state.dataList.where((data) => data.select == true).forEach((c){
        c.fIDs?.forEach((v){
          idList.add(v);
        });
        c.cardNos?.forEach((b){
          cardList.add(b);
        });
    });

    httpPost(
      method: webApiGetBarcodeDetails,
      loading: 'process_dispatch_get_detail'.tr,
      body: {
        'InterID':
            state.dataList.firstWhere((data) => data.select == true).interID,
        'FIDs': idList,
        'CardNos':cardList,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.workCardDetail =
            ProcessWorkCardDetailInfo.fromJson(response.data);

        setSizeList();
        state.showLabelList.value = state.workCardDetail!.barcodes!;

        state.instructionList.clear();

        for (var v in state.workCardDetail!.mtoNoSizes!) {
          //指令
          if (!state.instructionList.contains(v.mtoNo) && v.mtoNo != '') {
            state.instructionList.add(v.mtoNo!);
          }
        }

        if (toPage) {
          Get.to(() => const ProcessDispatchDetailPage());
        } else {
          state.showLabelList.refresh();
        }
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //设置尺码的数据  然后筛选色系
  void setSizeList() {
    state.showDetailList.clear();
    state.showDetailList.value = state.workCardDetail!.sizes!;
    addAll();

    state.colorList.clear();
    for (var v in state.workCardDetail!.sizes!) {
      //色系
      if (!state.colorList.contains(v.sAPColorBatch) && v.sAPColorBatch != '') {
        state.colorList.add(v.sAPColorBatch!);
      }
    }

    state.showDetailList.refresh();
  }

  //添加汇总
  void addAll() {
    state.showDetailList.add(SizeLists(
      size: '总',
      fIDs: [],
      mtonoQty: state.showDetailList
          .map((sub) => sub.mtonoQty)
          .fold(0.0, (total, capacity) => total.add(capacity ?? 0.0)),
      createdQty: state.showDetailList
          .map((sub) => sub.createdQty)
          .fold(0.0, (total, created) => total.add(created ?? 0.0)),
      qty: state.showDetailList
          .map((sub) => sub.qty)
          .fold(0.0, (total, qty) => total.add(qty ?? 0.0)),
      sAPColorBatch: '',
    ));
  }

  //是否全选
  void selectAllData() {
    for (var v in state.showDetailList) {
      v.select = state.selectAllList.value;
    }
    state.showDetailList.refresh();
  }

  //选择具体尺码
  void selectSize(int position) {
    state.showDetailList[position].select =
    !state.showDetailList[position].select;

    state.showDetailList[position].boxCapacity = state.showDetailList[position].qty.toShowString();
    state.showDetailList.refresh();
  }

  //输入箱容
  void inputCapacity(String capacity, int position) {
    state.showDetailList[position].boxCapacity = capacity;
    state.showDetailList[position].select = true;
    state.showDetailList.refresh();
  }

  //色系排序
  void sortColorData() {
    if (state.colorList.isNotEmpty) {
      //创建选择器控制器
      var controller = FixedExtentScrollController(
        initialItem: 0,
      );
      //创建取消按钮
      var cancel = TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          'dialog_default_cancel'.tr,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
      );
      //创建确认按钮
      var confirm = TextButton(
        onPressed: () {
          Get.back();

          state.showDetailList.removeLast();
          state.showDetailList.sort((a, b) {
            bool aIsTarget =
                a.sAPColorBatch == state.colorList[controller.selectedItem];
            bool bIsTarget =
                b.sAPColorBatch == state.colorList[controller.selectedItem];
            if (aIsTarget && !bIsTarget) {
              return -1; // a 应该排在 b 前面
            } else if (!aIsTarget && bIsTarget) {
              return 1; // b 应该排在 a 前面
            } else {
              return 0; // a 和 b 的顺序不变
            }
          });
          addAll();
          state.showDetailList.refresh();
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );
      //创建底部弹窗
      showPopup(Column(
        children: <Widget>[
          //选择器顶部按钮
          Container(
            height: 45,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [cancel, confirm],
            ),
          ),
          //选择器主体
          Expanded(
            child: getCupertinoPicker(
              items: state.colorList.map((data) {
                return Center(child: Text(data));
              }).toList(),
              controller: controller,
            ),
          )
        ],
      ));
    }
  }

  //指令筛选
  void sortInstructionData() {
    if (state.colorList.isNotEmpty) {
      //创建选择器控制器
      var controller = FixedExtentScrollController(
        initialItem: 0,
      );
      //创建取消按钮
      var cancel = TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          'dialog_default_cancel'.tr,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
      );
      //创建确认按钮
      var confirm = TextButton(
        onPressed: () {
          Get.back();

          state.showDetailList.clear();
          state.showDetailList.value = state.workCardDetail!.mtoNoSizes!
              .where((data) =>
                  data.mtoNo == state.instructionList[controller.selectedItem])
              .toList();

          state.colorList.clear();
          for (var v in state.showDetailList) {
            //色系
            if (!state.colorList.contains(v.sAPColorBatch) &&
                v.sAPColorBatch != '') {
              state.colorList.add(v.sAPColorBatch!);
            }
          }
          addAll();
          state.showDetailList.refresh();
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );
      //创建底部弹窗
      showPopup(Column(
        children: <Widget>[
          //选择器顶部按钮
          Container(
            height: 45,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [cancel, confirm],
            ),
          ),
          //选择器主体
          Expanded(
            child: getCupertinoPicker(
              items: state.instructionList.map((data) {
                return Center(child: Text(data));
              }).toList(),
              controller: controller,
            ),
          )
        ],
      ));
    }
  }

  //创建贴标
  void createLabel({
    required Function(String) success,
  }) {
    if (state.showDetailList.none((data) => data.select == true)) {
      showSnackBar(message: 'process_dispatch_tab1_select_size'.tr);
    } else if (state.showDetailList
        .where((data) =>
            data.select == true && data.boxCapacity.toDoubleTry() <= 0)
        .isNotEmpty) {
      showSnackBar(message: 'process_dispatch_tab1_select_capacity_empty'.tr);
    } else {
      httpPost(
        method: webApiCreateLabelingBarcode,
        loading: 'process_dispatch_tab1_create_label'.tr,
        body: {
          'SizeItems': [
            for (var v in state.showDetailList.where((data) => data.select))
              {
                'FID': v.fIDs,
                'Size': v.size,
                'BoxCapacity': v.boxCapacity,
              }
          ],
          'LabelCount': state.createLabelQty,
          'BarCodeType': state.submitType.value == '单码' ? '1' : '2',
          'UserID': userInfo?.userID,
          'DeptID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(
              response.message ?? 'process_dispatch_tab1_create_success'.tr);
        } else {
          errorDialog(
              content:
                  response.message ?? 'process_dispatch_tab1_create_fail'.tr);
        }
      });
    }
  }

  //切换单混码
  void clickType() {
    if (state.submitType.value == '单码') {
      state.submitType.value = '混码';
    } else {
      state.submitType.value = '单码';
    }
  }

  //选择贴标
  void selectLabel(int position) {
    state.showLabelList[position].select =
        !state.showLabelList[position].select;
    state.showLabelList.refresh();
  }

  //删除贴标
  void deleteLabel({
    required bool batch,
    required int position,
    required Function(String) success,
  }) {
    var list = <String>[];
    if(batch){
      state.showLabelList.where((label)=> label.select==true).forEach((c){
        list.add(c.barcode!);
      });
    }else{
      list.add(state.showLabelList[position].barcode!);
    }
    httpPost(
      method: webApiDelLabelingBarcode,
      loading: 'process_dispatch_label_deleting'.tr,
      body: {
        'Barcodes': list,
        'UserID': userInfo?.userID,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
            response.message ?? 'process_dispatch_label_delete_success'.tr);
      } else {
        errorDialog(
            content:
                response.message ?? 'process_dispatch_label_delete_fail'.tr);
      }
    });
  }


  //更新打印状态
  void updatePartsPrintTimes({
    required bool select,
    required int position,
    required Function() success,
  }) {
    var list = <Map<String, String>>[];
    if(select){
      state.showLabelList.where((label)=>label.select == true).forEach((v){
        list.add({'BarCode': v.barcode!});
      });
    }else{
      list.add({'BarCode': state.showLabelList[position].barcode!});
    }
    httpPost(
      method: webApiUpdatePartsPrintTimes,
      loading: 'process_dispatch_label_update_state'.tr,
      body: {
        'Barcodes': list,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        errorDialog(
            content: response.message ??
                'process_dispatch_label_update_print_fail'.tr);
      }
    });
  }

  //批量
  bool isBatch(){
    if(state.showLabelList.where((label)=> label.select == true).isNotEmpty){
      return true;
    }else{
      showSnackBar(message: 'process_dispatch_please_select_data'.tr);
      return false;
    }
  }


  //选择所有未打印的贴标
  void selectNoPrint(bool selectType){
    state.showLabelList.where((label)=> label.printTimes! <=0).forEach((c){
      c.select = selectType;
    });
    state.showLabelList.refresh();
  }

  //选择所有数据
  void selectAllLabel(bool isSelect){
    for (var v in state.showLabelList) {
        v.select = isSelect;
    }
    state.showLabelList.refresh();
  }

}
