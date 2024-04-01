import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:filipay/pages/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCam extends StatefulWidget {
  const QRCam({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCamState();
}

class _QRCamState extends State<QRCam> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // bool
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        '' /*'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}'*/)
                  else
                    const Text(''),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return Icon(Icons.flash_on);
                                }
                                return Icon(Icons.flash_off);
                              },
                            )),
                      ),
                      Text(
                        'Scan a code',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                return Icon(Icons.cameraswitch_sharp);
                              },
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 350.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 70,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          controller.dispose();
          ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      title: "Success!",
                      text: "QR Code Scanned Successfully"))
              .then((value) {
            // controller.resumeCamera();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainPage(),
              ),
            );
          });
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

//   void _showModalPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Loading...'),
//         content: CircularProgressIndicator(),
//       );
//     },
//   );
// }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
