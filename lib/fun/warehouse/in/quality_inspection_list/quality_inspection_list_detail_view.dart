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
  int index = Get.arguments['index'];

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
                        flex: 3,
                        child: Text('quality_inspection_tracking_number'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_delivery_location'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_size'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_unit'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_company_code'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_factory'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_inspection_order'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_contract_number'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_temporary_receipt'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_tax_code'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_procurement_type'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_factory_type_detail'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_distributive_form'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_material_document'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_storage_location'.tr),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text('quality_inspection_reason'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_creator'.tr),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('quality_inspection_parity'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_temporary_date'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_creation_date'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_creation_time'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_note'.tr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('quality_inspection_offset_voucher'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_reversal_reason'.tr),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('quality_inspection_delete_reason'.tr),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.showDataList[index].length,
                    itemBuilder: (c, i) =>
                        _QiListDetailItem(item: state.showDataList[index][i]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _QiListDetailItem extends StatelessWidget {
  final StuffQualityInspectionInfo item;
  const _QiListDetailItem({required this.item});

  @override
  Widget build(BuildContext context) {
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
              flex: 3,
              child: Text(item.trackNo ?? ''),
            ),
            Expanded(
              flex: 3,
              child: Text(item.deliAddress ?? ''),
            ),
            Expanded(
              flex: 2,
              child: Text(item.characteristicValue ?? ''),
            ),
            Expanded(
              flex: 3,
              child: Text(item.commonUnits ?? ''),
            ),
            Expanded(
              flex: 2,
              child: Text(item.companyCode ?? ' '),
            ),
            Expanded(
              flex: 2,
              child: Text(item.factoryNumber ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(item.inspectionOrderNo ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(item.purchaseVoucherNo ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(item.temporaryNo ?? ''),
            ),
            Expanded(
              flex: 2,
              child: Text(item.taxCode ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(item.sourceOrderType ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(
                item.factoryType ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                item.distributiveForm ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                item.materialDocumentNo ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.location1 ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 6,
              child: InkWell(
                child: Text(
                  item.unqualifiedReason ?? '',
                  maxLines: 1,
                ),
                onTap: () {
                  showSnackBar(message: item.unqualifiedReason.toString());
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(item.biller ?? ''),
            ),
            Expanded(
              flex: 2,
              child: Text(item.inspectionMethod ?? ''),
            ),
            Expanded(
              flex: 3,
              child: Text(item.tempreBillDate ?? ''),
            ),
            Expanded(
              flex: 3,
              child: Text(item.billDate ?? ''),
            ),
            Expanded(
              flex: 3,
              child: Text(item.billTime ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(
                item.remarks ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(item.materialDocumentNumberReversal ?? ''),
            ),
            Expanded(
              flex: 4,
              child: Text(
                item.remarks1 ?? '',
                maxLines: 1,
              ),
            ),
            Expanded(
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
}
