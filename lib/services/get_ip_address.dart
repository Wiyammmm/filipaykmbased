import 'dart:io';
import 'package:connectivity/connectivity.dart';

class IPAddressService {
  Future<String> getWifiIP() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        // Check if it's an IPv4 address and not a loopback address
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }

    return 'Unknown';
  }

  Future<String> getIpAddress() async {
    String wifiIp = '';

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.wifi) {
        wifiIp = await getWifiIP();
      }
    } catch (e) {
      wifiIp = 'IP Error: $e';
    }

    return wifiIp;
  }
}
