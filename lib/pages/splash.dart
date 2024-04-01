import 'package:filipay/pages/login.dart';
import 'package:filipay/services/getDeviceInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  DeviceInfoService deviceInfoService = DeviceInfoService();
  String serialNumber = "";
  final _myBox = Hive.box('myBox');
  @override
  void initState() {
    super.initState();
    getSerialNumber();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(_controller);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ));
      }
    });
  }

  Future<void> getSerialNumber() async {
    serialNumber = await deviceInfoService.getDeviceSerialNumber();
    print('serialNumber: $serialNumber');
    _myBox.put('SESSION', {"sNo": "$serialNumber"});
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Center(
                child: Image(
                  image: AssetImage('assets/filipay-logo-w-name.png'),
                  width: 180,
                  height: 180,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
