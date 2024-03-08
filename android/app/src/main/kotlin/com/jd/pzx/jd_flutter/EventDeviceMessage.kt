package com.jd.pzx.jd_flutter

enum class DeviceType{
    PdaScanner,
    UsbWeighbridge,
    UsbMeterCounter,
    BluetoothTscPrinter,
    UsbTscPrinter
}
data class EventDeviceMessage(
    var deviceType:DeviceType,
    var message:String,
    var data:Any
)