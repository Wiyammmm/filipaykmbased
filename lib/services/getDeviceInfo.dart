import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';

class DeviceInfoService {
  static const platform = const MethodChannel("com.flutter.epic/epic");
  Future<String> getDeviceSerialNumber() async {
    // String? identifier;
    String value = '';
    // Map<String, dynamic> allInfo = {};
    try {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        value = await platform.invokeMethod("Printy");
//         identifier = await UniqueIdentifier.serial;
// //      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
// // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         print('identifier serial#: $identifier');
//         final deviceInfoPlugin = DeviceInfoPlugin();
//         final deviceInfo = await deviceInfoPlugin.deviceInfo;
//         allInfo = deviceInfo.data;

//         print('allInfo: $allInfo');
//         print(deviceInfo.data['serialNumber']);
      }
    } catch (e) {
      // Handle errors or exceptions here
      print('Error getting device information: $e');
    }

    return value;
  }

 
}
