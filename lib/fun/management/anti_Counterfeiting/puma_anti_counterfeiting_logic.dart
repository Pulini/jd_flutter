import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/bean/http/response/puma_box_code_info.dart';
import 'package:jd_flutter/bean/http/response/puma_code_list_info.dart';
import 'package:jd_flutter/fun/management/anti_Counterfeiting/puma_anti_counterfeiting_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PumaAntiCounterfeitingLogic extends GetxController {
  final PumaAntiCounterfeitingState state = PumaAntiCounterfeitingState();

  ///获取箱标详情
  getBarCodeListByBoxNumber(String boxNumber) {
    if (boxNumber.isEmpty) {
    } else {
      if (boxNumber.startsWith("GE") &&
          boxNumber.length >= 10 &&
          boxNumber.length <= 13) {
        httpGet(
          method: webApiGetBarCodeListByBoxNumber,
          loading: '正在获取箱标详情...',
        ).then((response) {
          if (response.resultCode == resultSuccess) {
            var list = <PumaBoxCodeInfo>[
              for (var i = 0; i < response.data.length; ++i)
                PumaBoxCodeInfo.fromJson(response.data[i])
            ];
            state.dataList.value = list;
          } else {
            errorDialog(content: response.message);
          }
        });
      } else {
        showSnackBar(title: '警告', message: '箱标错误');
      }
    }
  }

  ///提交入库
  submitCode() {
    httpPost(
      method: webApiBarCodeInStock,
      loading: '正在入库...',
      body: {
        'BoxNumber': state.palletNumber.value,
        'WorkCode': getUserInfo()!.number,
        'BarCodeList': [
          for (var i = 0; i < state.dataCodeList.length; ++i)
            state.dataCodeList[i].code
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message,
            back: () => {state.clearData(), state.setScanNum()});
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  ///获取拣货标签列表
  getBarCodeListByEmp() {
    httpGet(
      method: webApiGetBarCodeListByEmp,
      loading: '正在获取分拣数据...',
      params: {
        'WorkCode': getUserInfo()!.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <PumaCodeListInfo>[
          for (var i = 0; i < response.data.length; ++i)
            PumaCodeListInfo.fromJson(response.data[i])
        ];
        state.sortingList.value = list;
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  ///扫描条码判断是否扫过
  haveCode({
    required String code,
    required Function() have,
  }) {
    if (state.sortingList.isNotEmpty) {
      if (code.isEmpty) {
        showSnackBar(title: '警告', message: '条码为空');
      } else {
        for (int i = 0; i < state.sortingList.length; i++) {
          if (state.sortingList[i].fBarCode == code) {
            state.sortingList[i].use = true;
            have.call();
            break;
          }
        }
        state.sortingList.sort((a, b) {
          if (a.use && !b.use) return -1;
          if (!a.use && b.use) return 1;
          return 0;
        });
      }
    } else {
      showSnackBar(title: '警告', message: '分拣数据为空');
    }
  }

  ///PUMA防伪标出库
  submitOutCode() {
    httpPost(
      method: webApiBarCodeOutStock,
      loading: '正在出库...',
      body: {
        'BoxNumber': "",
        'WorkCode': getUserInfo()!.number,
        'BarCodeList': [
          for (var i = 0; i < state.sortingList.length; ++i)
            {
              if (state.sortingList[i].use) {state.dataCodeList[i].code}
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {

        List <PumaCodeListInfo> list =  state.sortingList.where((data)=> data.use!=true).toList();
        state.sortingList.value = list;
        state.setSortingScanNum();

      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
