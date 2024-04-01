import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:filipay/class/client.dart';

import 'package:flutter/material.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

// import 'package:get_ip_address/get_ip_address.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controllerQR;

  Client? client;
  List<String> serverLogs = [];
  TextEditingController messageController = TextEditingController();
  String ipAddress = "";
  String _tagId = "";

  bool isOpenQr = false;
  bool isQrdetected = false;

  initState() {
    super.initState();

    _connectToServer();
    // _getIPAddress();
    // _continuesQrScan();
  }

  @override
  void dispose() {
    messageController.dispose();
    client?.disconnect();
    controllerQR?.dispose();
    super.dispose();
  }

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controllerQR!.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controllerQR!.resumeCamera();
  //   }
  // }

  void _onQRViewCreated(QRViewController controller) {
    this.controllerQR = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isQrdetected) {
        print('scanData: ${scanData.code}');
        if (scanData.code != "" && scanData.code != null) {
          setState(() {
            isQrdetected = true;
            result = scanData;
            print('result: ${result?.code}');
          });
          ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      title: "A success message!",
                      text: "qrcode data: ${scanData.code}"))
              .then((value) {
            setState(() {
              isQrdetected = false;
            });
          });
        }
      }
    });
  }

  Future<void> _connectToServer() async {
    client = Client(
      hostname: "10.99.72.192",
      port: 4040,
      onData: this.onData,
      onError: this.onError,
    );
    await client?.connect();
  }

  onData(Uint8List data) {
    serverLogs.add(String.fromCharCodes(data));
    String jsonString = String.fromCharCodes(data);

    // Trim any leading/trailing characters if needed
    jsonString = jsonString.trim();
    jsonString = jsonString.substring(1, jsonString.length - 1);
    // Split the string by commas
    List<String> parts = jsonString.split(',');
    print('parts: $parts');
    // Create an empty map
    Map<String, dynamic> jsonMap = {};

    // Loop through parts and split each part by colon to create key-value pairs

    // if (parts.isNotEmpty) {
    try {
      parts.forEach((part) {
        List<String> keyValue = part.split(':');
        // Remove leading/trailing spaces and quotes
        String key = keyValue[0].trim().replaceAll('"', '');
        String value = keyValue[1].trim().replaceAll('"', '');
        jsonMap[key] = value;
      });
    } catch (e) {
      print("parts error: $e");
    }

    // }

    // Map<String, dynamic> jsonMap = json.decode("${String.fromCharCodes(data)}");
    print('jsonMap: $jsonMap');
    if (jsonMap['message'].toString() == "logout") {
      print('logout na din');
      confirmReturn();
    }

    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ATTENTION"),
          content: Text(
              "Leaving this page will disconnect the client from the socket server"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("EXIT", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: confirmReturn,
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: QRView(
                    key: qrKey,
                    overlay: QrScannerOverlayShape(
                        //customizing scan area
                        borderWidth: 10,
                        borderColor: Color.fromARGB(255, 0, 91, 165),
                        borderLength: 15,
                        borderRadius: 10,
                        cutOutSize: MediaQuery.of(context).size.width * 0.7,
                        overlayColor: Colors.blue.withOpacity(0.5)),
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isOpenQr = false;
                            });
                          },
                          child: Text('Close'))
                    ],
                  ),
                )
              ],
            ),
          ),
          if (!isOpenQr)
            Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Client",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: client!.connected
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                ),
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  client!.connected
                                      ? 'CONNECTED'
                                      : 'DISCONNECTED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (client!.connected) {
                                await client!.disconnect();
                                this.serverLogs.clear();
                              } else {
                                await client!.connect();
                              }
                              setState(() {});
                            },
                            child: Text(!client!.connected
                                ? 'CONNECT TO CLIENT'
                                : 'DISCONNECT TO CLIENT'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isOpenQr = true;
                              });
                            },
                            child: Text('OPEN QR CODE'),
                          ),
                          Divider(
                            height: 30,
                            thickness: 1,
                            color: Colors.black12,
                          ),
                          Expanded(
                            flex: 1,
                            child: ListView(
                              children: serverLogs.map((String log) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(log),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey,
                  height: 80,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'MESSAGE TO SEND:',
                              style: TextStyle(
                                fontSize: 8,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: messageController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      MaterialButton(
                        onPressed: () {
                          messageController.text = "";
                        },
                        minWidth: 30,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Icon(Icons.clear),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      MaterialButton(
                        onPressed: () {
                          client!.write({"cardId": "$_tagId", "amount": 100});

                          messageController.text = "";
                          messageController.text = "";
                        },
                        minWidth: 30,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Icon(Icons.send),
                      )
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
