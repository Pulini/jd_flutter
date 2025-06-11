import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class QualityInspectionListDetailPage extends StatefulWidget {
  const QualityInspectionListDetailPage({super.key});

  @override
  State<QualityInspectionListDetailPage> createState() =>
      _QualityInspectionListDetailPageState();
}

class _QualityInspectionListDetailPageState
    extends State<QualityInspectionListDetailPage> {
  final QualityInspectionListLogic logic =
      Get.find<QualityInspectionListLogic>();
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;

  Widget _item(StuffQualityInspectionInfo item) {
    return SizedBox(
      width: 120 * 23,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              //跟踪号
              flex: 3,
              child: Text(item.trackNo ?? ''),
            ),
            Expanded(
              //送货地点
              flex: 3,
              child: Text(item.deliAddress ?? ''),
            ),
            Expanded(
              //尺码
              flex: 2,
              child: Text(item.characteristicValue ?? ''),
            ),
            Expanded(
              //常用单位
              flex: 3,
              child: Text(item.commonUnits ?? ''),
            ),
            Expanded(
              //公司代码
              flex: 2,
              child: Text(item.companyCode ?? ' '),
            ),
            Expanded(
              //工厂
              flex: 2,
              child: Text(item.factoryNumber ?? ''),
            ),
            Expanded(
              //检验单号
              flex: 4,
              child: Text(item.inspectionOrderNo ?? ''),
            ),
            Expanded(
              // 合同号
              flex: 4,
              child: Text(item.purchaseVoucherNo ?? ''),
            ),
            Expanded(
              //暂收单号
              flex: 4,
              child: Text(item.temporaryNo ?? ''),
            ),
            Expanded(
              //税码
              flex: 2,
              child: Text(item.taxCode ?? ''),
            ),
            Expanded(
              //采购类型
              flex: 4,
              child: Text(item.sourceOrderType ?? ''),
            ),
            Expanded(
              //工厂型体
              flex: 4,
              child: Text(
                item.factoryType ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //分配型体
              flex: 4,
              child: Text(
                item.distributiveForm ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //物料凭证
              flex: 4,
              child: Text(
                item.materialDocumentNo ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //货位
              flex: 3,
              child: Text(
                item.location1 ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //不合格原因
              flex: 3,
              child: Text(
                item.unqualifiedReason ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //制单人
              flex: 2,
              child: Text(item.biller ?? ''),
            ),
            Expanded(
              //检验方式
              flex: 2,
              child: Text(item.inspectionMethod ?? ''),
            ),
            Expanded(
              //暂收日期
              flex: 3,
              child: Text(item.tempreBillDate ?? ''),
            ),
            Expanded(
              //制单日期
              flex: 3,
              child: Text(item.billDate ?? ''),
            ),
            Expanded(
              //制单时间
              flex: 3,
              child: Text(item.billTime ?? ''),
            ),
            Expanded(
              //备注
              flex: 4,
              child: Text(
                item.remarks ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //冲销凭证
              flex: 3,
              child: Text(item.materialDocumentNumberReversal ?? ''),
            ),
            Expanded(
              //冲销原因
              flex: 4,
              child: Text(
                item.remarks1 ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              //删除原因
              flex: 4,
              child: Text(
                item.deleteReason ?? '',
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'quality_inspection_detail'.tr,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 120 * 23,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    color: Colors.green.shade100,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        //跟踪号
                        flex: 3,
                        child: Text(
                          'quality_inspection_tracking_number'.tr,
                        ),
                      ),
                      Expanded(
                        //送货地点
                        flex: 3,
                        child: Text(
                          'quality_inspection_delivery_location'.tr,
                        ),
                      ),
                      Expanded(
                        //尺码
                        flex: 2,
                        child: Text(
                          'quality_inspection_size'.tr,
                        ),
                      ),
                      Expanded(
                        //常用单位
                        flex: 3,
                        child: Text(
                          'quality_inspection_unit'.tr,
                        ),
                      ),
                      Expanded(
                        //公司代码
                        flex: 2,
                        child: Text(
                          'quality_inspection_company_code'.tr,
                        ),
                      ),
                      Expanded(
                        //工厂
                        flex: 2,
                        child: Text(
                          'quality_inspection_factory'.tr,
                        ),
                      ),
                      Expanded(
                        //检验单号
                        flex: 4,
                        child: Text(
                          'quality_inspection_inspection_order'.tr,
                        ),
                      ),
                      Expanded(
                        // 合同号
                        flex: 4,
                        child: Text(
                          'quality_inspection_contract_number'.tr,
                        ),
                      ),
                      Expanded(
                        //暂收单号
                        flex: 4,
                        child: Text(
                          'quality_inspection_temporary_receipt'.tr,
                        ),
                      ),
                      Expanded(
                        //税码
                        flex: 2,
                        child: Text(
                          'quality_inspection_tax_code'.tr,
                        ),
                      ),
                      Expanded(
                        //采购类型
                        flex: 4,
                        child: Text(
                          'quality_inspection_procurement_type'.tr,
                        ),
                      ),
                      Expanded(
                        //工厂型体
                        flex: 4,
                        child: Text(
                          'quality_inspection_factory_type_detail'.tr,
                        ),
                      ),
                      Expanded(
                        //分配型体
                        flex: 4,
                        child: Text(
                          'quality_inspection_distributive_form'.tr,
                        ),
                      ),
                      Expanded(
                        //物料凭证
                        flex: 4,
                        child: Text(
                          'quality_inspection_material_document'.tr,
                        ),
                      ),
                      Expanded(
                        //货位
                        flex: 3,
                        child: Text(
                          'quality_inspection_storage_location'.tr,
                        ),
                      ),
                      Expanded(
                        //不合格原因
                        flex: 3,
                        child: Text(
                          'quality_inspection_reason'.tr,
                        ),
                      ),
                      Expanded(
                        //制单人
                        flex: 2,
                        child: Text(
                          'quality_inspection_creator'.tr,
                        ),
                      ),
                      Expanded(
                        //检验方式
                        flex: 2,
                        child: Text(
                          'quality_inspection_parity'.tr,
                        ),
                      ),
                      Expanded(
                        //暂收日期
                        flex: 3,
                        child: Text(
                          'quality_inspection_temporary_date'.tr,
                        ),
                      ),
                      Expanded(
                        //制单日期
                        flex: 3,
                        child: Text(
                          'quality_inspection_creation_date'.tr,
                        ),
                      ),
                      Expanded(
                        //制单时间
                        flex: 3,
                        child: Text(
                          'quality_inspection_creation_time'.tr,
                        ),
                      ),
                      Expanded(
                        //备注
                        flex: 4,
                        child: Text(
                          'quality_inspection_note'.tr,
                        ),
                      ),
                      Expanded(
                        //冲销凭证
                        flex: 3,
                        child: Text(
                          'quality_inspection_offset_voucher'.tr,
                        ),
                      ),
                      Expanded(
                        //冲销原因
                        flex: 4,
                        child: Text(
                          'quality_inspection_reversal_reason'.tr,
                        ),
                      ),
                      Expanded(
                        //删除原因
                        flex: 4,
                        child: Text(
                          'quality_inspection_delete_reason'.tr,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.showDetailDataList.length,
                    itemBuilder: (c, i) => _item(state.showDetailDataList[i]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
