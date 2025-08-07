import UIKit
import Flutter
import CoreBluetooth


@main
@objc class AppDelegate: FlutterAppDelegate {
    var channel="channel_bluetooth_flutter_to_android"
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: channel,binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            print("method=\(call.method)")
            switch call.method {
            case "IsEnable":
                self.bleHelper.startScan()
            case "GetScannedDevices":
                self.bleHelper.startScan()
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    var bleHelper = BluetoothUtil.shared
    var pArray:[CBPeripheral] = []
    func initBluetooth() {
        bleHelper.setPeripheralsBlock { (peArray) in
            self.pArray = peArray
            peArray.forEach { ble in
//                ble.name
                print(ble)
                
            }
        }
        
        bleHelper.setConnectedBlock { (backPe, backCh) in
            print("设备已连接，peripheral:\(backPe)，characteristic:\(backCh)")
        }
        
        bleHelper.setDataBlock { (data) in
            print("ble data:\([UInt8](data))")
        }
    }
}
