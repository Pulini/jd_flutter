
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/bluetooth_device.dart';

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({super.key});

  @override
  State<BluetoothDialog> createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {

  var deviceList = <BluetoothDevice>[].obs;
  var streamIsScanning = false.obs;

  // @override
  // void initState() {
  //   super.initState();
  //   if (GetPlatform.isAndroid) {
      // getBluetoothPermission().then((isGranted) {
      //   if (isGranted) {
      //     _bluetoothListener();
      //     _getScannedDevices();
      //   } else {
      //     Get.back();
      //   }
      // });
  //   }
  //   if (GetPlatform.isIOS) {
  //     _bluetoothListener();
  //     _getScannedDevices();
  //   }
  // }

  // _item(BluetoothDevice device) {
  //   return Card(
  //     child: ListTile(
  //       leading: const Icon(
  //         Icons.bluetooth,
  //         color: Colors.blueAccent,
  //       ),
  //       title: device.deviceIsBonded!
  //           ? Text.rich(
  //               TextSpan(
  //                 children: [
  //                   TextSpan(
  //                     text: device.deviceName,
  //                   ),
  //                   TextSpan(
  //                     text: 'bluetooth_connected'.tr,
  //                     style: const TextStyle(
  //                       color: Colors.green,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )
  //           : Text(device.deviceName!),
  //       subtitle: Text(device.deviceMAC!),
  //       trailing: device.deviceIsConnected!
  //           ? TextButton(
  //               onPressed: () => _closeBluetooth(device),
  //               child: Text.rich(
  //                 TextSpan(
  //                   style: const TextStyle(color: Colors.red),
  //                   children: [
  //                     const WidgetSpan(
  //                       child: Icon(
  //                         Icons.square,
  //                         color: Colors.red,
  //                       ),
  //                       alignment: PlaceholderAlignment.middle,
  //                     ),
  //                     TextSpan(text: 'bluetooth_disconnect'.tr),
  //                   ],
  //                 ),
  //               ))
  //           : TextButton(
  //               onPressed: () => _connectBluetooth(device),
  //               child: Text('bluetooth_connect'.tr),
  //             ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Dialog(
    //   backgroundColor: Colors.white,
    //   child: SizedBox(
    //     width: 400,
    //     height: 600,
    //     child: Padding(
    //         padding: const EdgeInsets.all(15),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Expanded(
    //                 child: Obx(() => ListView.builder(
    //                       padding: const EdgeInsets.all(8),
    //                       itemCount: deviceList.length,
    //                       itemBuilder: (BuildContext context, int index) =>
    //                           _item(deviceList[index]),
    //                     ))),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 Expanded(
    //                   flex: 1,
    //                   child: ElevatedButton(
    //                     onPressed: () => Get.back(),
    //                     child: Text(
    //                       'bluetooth_back'.tr,
    //                       style: const TextStyle(color: Colors.grey),
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(width: 10),
    //                 Obx(() => Expanded(
    //                       flex: 1,
    //                       child: streamIsScanning.value
    //                           ? ElevatedButton(
    //                               onPressed: () => _endScanBluetooth(),
    //                               child: Text.rich(
    //                                 TextSpan(
    //                                   style: const TextStyle(color: Colors.red),
    //                                   children: [
    //                                     const WidgetSpan(
    //                                       child: Icon(
    //                                         Icons.square,
    //                                         color: Colors.red,
    //                                       ),
    //                                       alignment:
    //                                           PlaceholderAlignment.middle,
    //                                     ),
    //                                     TextSpan(text: 'bluetooth_stop'.tr),
    //                                   ],
    //                                 ),
    //                               ),
    //                             )
    //                           : ElevatedButton(
    //                               onPressed: () => _isEnable((enable) => enable
    //                                   ? _scanBluetooth()
    //                                   : errorDialog(
    //                                       content:
    //                                           'bluetooth_connect_error_type3'
    //                                               .tr)),
    //                               child: Text.rich(
    //                                 TextSpan(
    //                                   style:
    //                                       const TextStyle(color: Colors.green),
    //                                   children: [
    //                                     const WidgetSpan(
    //                                       child: Icon(
    //                                         Icons.play_arrow,
    //                                         color: Colors.green,
    //                                       ),
    //                                       alignment:
    //                                           PlaceholderAlignment.middle,
    //                                     ),
    //                                     TextSpan(text: 'bluetooth_scan'.tr),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                     ))
    //               ],
    //             ),
    //           ],
    //         )),
    //   ),
    // );
  }
}
