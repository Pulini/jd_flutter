import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_110w.dart';
import 'package:jd_flutter/widget/tsc_label_templates/fixed_label_75w45h.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_75w.dart';

class TscLabelPreview extends StatefulWidget {
  const TscLabelPreview({super.key});

  @override
  State<TscLabelPreview> createState() => _TscLabelPreviewState();
}

class _TscLabelPreviewState extends State<TscLabelPreview> {
  @override
  Widget build(BuildContext context) {
    var labels = <List>[
      [
        false,
        '(75 x 45)mm 料头标签 中文标签',
        surplusMaterialLabel(
          qrCode: '12345678987654321234567890',
          machine: 'JT021',
          shift: '昼班',
          startDate: '2025-01-01',
          typeBody: 'typeBody typeBody',
          materialName: 'materialName materialName materialName',
          materialCode: 'materialCode',
        )
      ],
      [
        false,
        '(75 x 45)mm 机台派工 中文标签',
        machineDispatchChineseFixedLabel(
          labelID: 'labelID',
          factoryType: 'factoryType',
          processes: 'processes',
          number: '1-1',
          materialName: 'materialName materialName',
          dispatchNumber: 'dispatchNumber',
          decrementNumber: '99-100',
          date: '2025-01-01',
          size: '35',
          qty: 999.99,
          unit: '双',
          shift: '昼班',
          machine: 'JT01',
          isLastLabel: false,
        )
      ],
      [
        false,
        '(75 x 45)mm 机台派工 尾标 中文标签',
        machineDispatchChineseFixedLabel(
          labelID: 'labelID',
          factoryType: 'factoryType',
          processes: 'processes',
          number: '1-1',
          materialName: 'materialName materialName',
          dispatchNumber: 'dispatchNumber',
          decrementNumber: '99-100',
          date: '2025-01-01',
          size: '35',
          qty: 999.99,
          unit: '双',
          shift: '昼班',
          machine: 'JT01',
          isLastLabel: true,
        )
      ],
      [
        false,
        '(75 x 45)mm 机台派工 英文标签',
        machineDispatchEnglishFixedLabel(
          labelID: 'labelID',
          factoryType: 'factoryType',
          englishName: 'englishName englishName',
          grossWeight: 99.9,
          netWeight: 99.9,
          specifications: '10x20x30',
          number: '1-1',
          dispatchNumber: 'dispatchNumber',
          decrementNumber: '99-99',
          date: '2025-01-01',
          qty: 999.99,
          englishUnit: 'u',
          size: '35',
        )
      ],
      [
        false,
        '(75 x 45)mm 湿印工序派工单标签',
        processDispatchRegisterLabel(
          barCode: 'barCode',
          typeBody: 'typeBody',
          processName: 'processName',
          instructionsText: 'instructionsText',
          empNumber: '012345',
          empName: '张三',
          size: '35',
          mustQty: 99.9,
          unit: '双',
          rowID: 10,
        )
      ],
      [
        false,
        '(75 x 45)mm 贴标维护物料 中文标签',
        maintainLabelMaterialChineseFixedLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          pageNumber: '9-10',
          qty: 999.99,
          unit: '双',
        )
      ],
      [
        false,
        '(75 x 45)mm 贴标维护物料 英文标签',
        maintainLabelMaterialEnglishFixedLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          grossWeight: 99.9,
          netWeight: 88.8,
          meas: 'meas',
          pageNumber: '9-10',
          qty: 999.99,
          unit: 'u',
        )
      ],
      [
        false,
        '(75 x 45)mm 贴标维护单件尺码 中文标签',
        maintainLabelSingleSizeChineseFixedLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          size: '35',
          pageNumber: '9-10',
          date: '2025-01-01',
          unit: '双',
        )
      ],
      [
        false,
        '(75 x 45)mm 贴标维护单件尺码 英文标签',
        maintainLabelSingleSizeEnglishFixedLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          grossWeight: 99.9,
          netWeight: 88.8,
          meas: '10x20x30',
          qty: 999.99,
          pageNumber: '1-1',
          size: '35',
          unit: 'PAA'
        )
      ],
      [
        false,
        '(75 x 45)mm sap wms标签拆分 1101仓库标签',
        sapWmsSplitLabel1101WarehouseLabel(
          labelNumber: 'labelNumber',
          factory: 'factory',
          process: 'process',
          materialName: 'materialName materialName',
          dispatchNumber: 'dispatchNumber',
          decrementTableNumber: '99-199',
          numPage: '1-1',
          dispatchDate: '25-01-02',
          dayOrNightShift: '昼班',
          machineNumber: 'JT02',
          size: '35',
          boxCapacity: 99.9,
          unit: '双',
        )
      ],
      [
        false,
        '(75 x 45)mm sap wms标签拆分 1102 1105仓库标签',
        sapWmsSplitLabel1102And1105WarehouseLabel(
          labelNumber: 'labelNumber',
          typeBody: 'typeBody',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          numPage: '1-1',
          quantity: 999.99,
          unit: '双',
        )
      ],
      [
        false,
        '(75 x 45)mm sap wms标签拆分 1200仓库标签',
        sapWmsSplitLabel1200WarehouseLabel(
          labelNumber: 'labelNumber',
          typeBody: 'typeBody',
          instructionNo: 'instructionNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          grossWeight: 99.9,
          netWeight: 88.8,
          meas: '10x20x30',
          quantity: 999.99,
          unit: '双',
          numPage: '1-1',
          size: '35',
        )
      ],
      [
        false,
        '(75 x 45)mm sap wms标签拆分 其他仓库标签',
        sapWmsSplitLabelOtherWarehouseLabel(
          labelNumber: 'labelNumber',
          typeBody: 'typeBody',
          instructionNo: 'instructionNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName',
          numPage: '1-1',
          quantity: 999.99,
          unit: '双',
        )
      ],
      [
        true,
        '(75 x N)mm 标签维护尺码物料中文标',
        maintainLabelSizeMaterialChineseDynamicLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          total: 999.99,
          unit: 'unit',
          materialCode: 'materialCode',
          materialName: 'materialName materialName materialName',
          map: {
            '1000065698': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
            ],
            '1000065696': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
            ],
            '1000065695': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
            ],
          },
          titleText: '尺码',
          totalText: '合计',
          pageNumber: '1-1',
          deliveryDate: '2025-01-01',
        )
      ],
      [
        true,
        '(75 x N)mm 标签维护尺码物料英文标',
        maintainLabelSizeMaterialEnglishDynamicLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          materialCode: 'materialCode',
          materialName: 'materialName materialName materialName',
          grossWeight: 99.99,
          netWeight: 88.88,
          meas: '10x20x30',
          total: 999.99,
          unit: 'unit',
          map: {
            '1000065698': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['38', '77.7'],
              ['39', '77.7'],
              ['33', '77.7'],
              ['32', '77.7'],
            ],
            'billNo2': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
              ['38', '77.7'],
              ['39', '77.7'],
            ],
            'billNo3': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['34', '66.6'],
              ['33', '66.6'],
              ['37', '77.7'],
            ],
          },
          pageNumber: '1-1',
          deliveryDate: '2025-01-01',
        )
      ],
      [
        true,
        '(75 x N)mm 贴标维护混合中文标签',
        maintainLabelMixChineseDynamicLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          billNo: 'billNo',
          total: 999.99,
          unit: 'unit',
          materialCode: 'materialCode',
          materialName: 'materialName materialName materialName',
          map: {
            '1000065698': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['38', '77.7'],
              ['39', '77.7'],
              ['33', '77.7'],
              ['32', '77.7'],
            ],
            'billNo2': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
              ['38', '77.7'],
              ['39', '77.7'],
            ],
            'billNo3': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['34', '66.6'],
              ['33', '66.6'],
              ['37', '77.7'],
            ],
          },
          pageNumber: '1-1',
          deliveryDate: '2025-01-01',
        )
      ],
      [
        true,
        '(75 x N)mm 贴标维护混合英文标签',
        maintainLabelMixEnglishDynamicLabel(
          barCode: 'barCode',
          factoryType: 'factoryType',
          materialCode: 'materialCode',
          materialName: 'materialName',
          grossWeight: 99.99,
          netWeight: 88.88,
          meas: '10x20x30',
          total: 999.99,
          unit: 'unit',
          map: {
            '10000657123': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['38', '77.7'],
              ['39', '77.7'],
              ['33', '77.7'],
              ['32', '77.7'],
            ],
            'billNo2': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['37', '77.7'],
              ['38', '77.7'],
              ['39', '77.7'],
            ],
            'billNo3': [
              ['35', '55.5'],
              ['36', '66.6'],
              ['34', '66.6'],
              ['33', '66.6'],
              ['37', '77.7'],
            ],
          },
          pageNumber: '1-1',
          deliveryDate: '2025-01-01',
        )
      ],

      //----------------1098----------------
      [
        true,
        '(110 x N)mm 1098 无尺码物料标',
        dynamicMaterialLabel1098(
          labelID: 'labelID',
          myanmarApprovalDocument: 'myanmarApprovalDocument',
          typeBody: 'typeBody',
          trackNo: '8123456',
          instructionNo: 'instructionNo',
          materialList: [
            [
              'materialCode1',
              '10x20x30',
              '99.9',
              'unit',
            ],
            [
              'materialCode2',
              '10x20x30',
              '99.9',
              'unit',
            ]
          ],
          customsDeclarationType: '报关形式',
          pieceNo: '1-1',
          pieceID: '1234567890',
          grossWeight: '66.6',
          netWeight: '77.7',
          specifications: '10x20x30',
          volume: '300',
          supplier: '供应商134567',
          manufactureDate: '2025-01-01',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1098 尺码物料标 单尺码',
        dynamicSizeMaterialLabel1098(
          labelID: 'labelID',
          myanmarApprovalDocument: 'myanmarApprovalDocument',
          typeBody: 'typeBody',
          trackNo: '2345432',
          materialList: {},
          instructionNo: 'instructionNo',
          materialCode: 'materialCode',
          size: '35',
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceNo: '11-1',
          pieceID: '12345678908',
          grossWeight: '88.8',
          netWeight: '99.9',
          specifications: '10x20x30',
          volume: '300',
          supplier: '供应商123456',
          manufactureDate: '2025-01-01',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1098 尺码物料标   多尺码',
        dynamicSizeMaterialLabel1098(
          labelID: 'labelID',
          myanmarApprovalDocument: 'myanmarApprovalDocument',
          typeBody: 'typeBody',
          trackNo: '2345432',
          materialList: {
            '尺码/Size/ukuran': ['35', '36', '37', '总计/total'],
            'instruction1': ['10', '20', '30', '60'],
            'instruction2': ['10', '20', '30', '60'],
            'instruction3': ['10', '20', '30', '60'],
            'instruction4': ['10', '20', '30', '60'],
          },
          instructionNo: 'instructionNo',
          materialCode: 'materialCode',
          size: '35',
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceNo: '11-1',
          pieceID: '12345678908',
          grossWeight: '88.8',
          netWeight: '99.9',
          specifications: '10x20x30',
          volume: '300',
          supplier: '供应商123456',
          manufactureDate: '2025-01-01',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      //----------------1095 1096----------------

      [
        true,
        '(110 x N)mm 1095 1096 外箱标 有物料列表',
        dynamicOutBoxLabel1095n1096(
          productName: 'productName',
          companyOrderType: '公司订单类型',
          customsDeclarationType: '报关形式',
          materialList: [
            [
              'materialCode1',
              '10x20x30',
              '99.9',
              'unit',
            ],
            [
              'materialCode2',
              '10x20x30',
              '99.9',
              'unit',
            ]
          ],
          pieceNo: '1-1',
          grossWeight: '77.7',
          netWeight: '88.8',
          qrCode: 'qrCodeqrCodeqrCodeqrCode',
          pieceID: '1234567890-9876',
          specifications: '10x20x30',
          volume: '300',
          supplier: '供应商123456',
          manufactureDate: '2025-01-01',
          consignee: '收货方123456',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1095 1096 外箱标  无物料列表',
        dynamicOutBoxLabel1095n1096(
          productName: 'productName',
          companyOrderType: '公司订单类型',
          customsDeclarationType: '报关形式',
          pieceNo: '1-1',
          grossWeight: '77.7',
          netWeight: '88.8',
          qrCode: 'qrCodeqrCodeqrCodeqrCode',
          pieceID: '1234567890-9876',
          specifications: '10x20x30',
          volume: '300',
          supplier: '供应商123456',
          manufactureDate: '2025-01-01',
          consignee: '收货方123456',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1095 1096 小标（无尺码标）',
        dynamicInBoxLabel1095n1096(
          haveSupplier: true,
          productName: 'productName',
          companyOrderType: 'factoryNo supplementType',
          customsDeclarationType: 'customsDeclarationType',
          materialList: [
            [
              'materialNumber1',
              'materialName materialName materialName',
              '777,77',
              'unit'
            ],
            [
              'materialNumber2',
              'materialName materialName materialName',
              '888,888',
              'unit'
            ],
            [
              'materialNumber3',
              'materialName materialName materialName',
              '999,99',
              'unit'
            ],
          ],
          pieceNo: '1-1',
          qrCode: '1234567890oiuytrewq',
          pieceID: '1234567890',
          manufactureDate: '2025-01-01',
          supplier: 'supplierNumber',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1095 1096 多尺码物料标',
        dynamicSizeMaterialLabel1095n1096(
          labelID: 'labelID',
          productName: 'productName',
          orderType: 'orderType',
          typeBody: 'typeBody',
          trackNo: '1234567',
          instructionNo: 'instructionNo',
          generalMaterialNumber: 'generalMaterialNumber',
          materialDescription: 'materialDescription',
          materialList: {
            '尺码/Size/ukuran': ['35', '36', '37', '总计/total'],
            'instruction1': ['10', '20', '30', '60'],
            'instruction2': ['10', '20', '30', '60'],
            'instruction3': ['10', '20', '30', '60'],
          },
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceID: '1234567890',
          pieceNo: '2-10',
          grossWeight: '99.9',
          netWeight: '88.8',
          specifications: '10x20x30',
          volume: '400',
          supplier: '供应商134567',
          manufactureDate: '2025-01-01',
          consignee: '收货方123456',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 1095 1096 单尺码/无尺码物料标',
        dynamicSizeMaterialLabel1095n1096(
          labelID: 'labelID',
          productName: 'productName',
          orderType: 'orderType',
          typeBody: 'typeBody',
          trackNo: '1234567',
          instructionNo: 'instructionNo',
          generalMaterialNumber: 'generalMaterialNumber',
          materialDescription: 'materialDescription',
          materialList: {},
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceID: '1234567890',
          pieceNo: '2-10',
          grossWeight: '99.9',
          netWeight: '88.8',
          specifications: '10x20x30',
          volume: '400',
          supplier: '供应商134567',
          manufactureDate: '2025-01-01',
          consignee: '收货方123456',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      //--------------国内标签----------
      [
        true,
        '(110 x N)mm 国内 无尺码物料标',
        dynamicDomesticMaterialLabel(
          labelID: 'labelID',
          productName: 'productName',
          orderType: 'orderType',
          materialNumber: 'materialNumber',
          materialDescription: 'materialDescription',
          materialList: {},
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceID: '1234567890',
          pieceNo: '2-10',
          grossWeight: '99.9',
          netWeight: '88.8',
          specifications: '10x20x30',
          volume: '400',
          supplierName: '供方名',
          manufactureDate: '2025-01-01',
          factoryWarehouse: '厂区仓库名称',
          hasNotes: true,
          notes: 'notes',
        )
      ],
      [
        true,
        '(110 x N)mm 国内 多尺码物料标',
        dynamicDomesticMaterialLabel(
          labelID: 'labelID',
          productName: 'productName',
          orderType: 'orderType',
          materialNumber: 'generalMaterialNumber',
          materialDescription: 'materialDescription',
          materialList: {
            '尺码': ['35', '36', '37', '总计'],
            'instruction1': ['10', '20', '30', '60'],
            'instruction2': ['10', '20', '30', '60'],
            'instruction3': ['10', '20', '30', '60'],
          },
          inBoxQty: '999.99',
          customsDeclarationUnit: '报关单位',
          customsDeclarationType: '报关形式',
          pieceID: '1234567890',
          pieceNo: '2-10',
          grossWeight: '99.9',
          netWeight: '88.8',
          specifications: '10x20x30',
          volume: '400',
          supplierName: '供方名',
          manufactureDate: '2025-01-01',
          factoryWarehouse: '厂区仓库名称',
          hasNotes: true,
          notes: 'notes',
        )
      ],
    ];
    return pageBody(
      title: '标签开发预览',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              for (var item in labels) ...[
                Text(
                  item[1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTap: (){
                      Get.to(() =>  PreviewLabel(labelWidget: item.last, isDynamic: item.first));
                    },
                    child: item.last,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
