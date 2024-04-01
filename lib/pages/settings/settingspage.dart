import 'package:filipay/class/client.dart';
import 'package:filipay/pages/settings/clientpage.dart';
import 'package:filipay/pages/settings/printerPage.dart';
import 'package:filipay/pages/settings/serverpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceinfo = {
      "sn": "V30823B620425", // serial number
      "deviceType": "server", // server || client
    };

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(134, 188, 227, 1.0),
          title: Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (deviceinfo['deviceType'] == "server") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ServerPage()));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ClientPage()));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mobile_friendly_outlined,
                          size: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          deviceinfo['deviceType'] == "server"
                              ? 'Server Status'
                              : 'Connect to device',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrinterPage()));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.print_rounded,
                          size: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Connect to printer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded)
                ],
              ),
              Divider(),
            ],
          )),
        ),
      ),
    );
  }
}
