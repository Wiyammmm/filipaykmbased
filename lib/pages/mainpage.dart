import 'dart:async';
import 'dart:typed_data';

import 'package:filipay/class/server.dart';
import 'package:filipay/components/buttons.dart';
import 'package:filipay/components/mycolors.dart';
import 'package:filipay/pages/settings/printerPage.dart';
import 'package:filipay/pages/settings/settingspage.dart';
import 'package:filipay/services/get_ip_address.dart';
import 'package:filipay/services/nfc.dart';
import 'package:filipay/services/printer/connectToPrinter.dart';
import 'package:filipay/services/printer/printReceipt.dart';
import 'package:filipay/widgets/modals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'background.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _myBox = Hive.box('myBox');
  Server? server;
  List<String> serverLogs = [];
  PrintServices printServices = PrintServices();
  PrinterController connectToPrinter = PrinterController();
  IPAddressService ipAddressService = IPAddressService();
  MyModal myModal = MyModal();
  nfcBackend nfcbackend = nfcBackend();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controllerQR;
  Timer? tapResetTimer;
  List<String> items = List.generate(20, (index) => 'Item $index');
  bool isOpenQr = false;
  bool isQrdetected = false;
  int tapCount = 0;
  String ipAddress = "";
  String _tagId = "";
  String serialNumber = "";
  FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    final SESSION = _myBox.get('SESSION');
    serialNumber = SESSION['sNo'];
    _startServer();
    _connectToPrinter();
    _initNFC();
    firebaseRDB();
    // startLocationTracking();

    super.initState();
  }

  void firebaseRDB() {
    print('firebaseRDB()');
    FirebaseDatabase.instance
        .ref()
        .child('filipayqr')
        .onChildAdded
        .listen((event) {
      print('Message changed: ${event.snapshot.value}');
      try {
        final dynamic thisData = event.snapshot.value;

        if (thisData?['deviceid'] == serialNumber &&
            thisData?['read'] == false) {
          print('received');
          _speak("${thisData?['amount']} pesos received, salamat!");
          printServices.printTicket(
              "0", "${thisData?['amount']}", "${thisData?['amount']}");
          final userReference = FirebaseDatabase.instance
              .ref()
              .child("filipayqr")
              .child(event.snapshot.key.toString());
          userReference.child("read").set(true);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future _speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }
  // Future<void> startLocationTracking() async {
  //   Location location = Location();
  //   bool serviceEnabled;
  //   PermissionStatus permissionGranted;

  //   serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       return;
  //     }
  //   }
  //   permissionGranted = await location.hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await location.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) {
  //       startLocationTracking();
  //       return;
  //     }
  //   }
  //   try {
  //     await location.enableBackgroundMode(enable: true);
  //     location.onLocationChanged.listen((LocationData newLocation) async {
  //       print('lat: ${newLocation.latitude}');
  //       print('long:${newLocation.longitude}');
  //     });
  //   } catch (e) {
  //     print("error startLocationTracking: $e");
  //     startLocationTracking();
  //   }
  // }

  // dispose() {
  //   server?.stop();
  //   super.dispose();
  // }

  Future<void> _startServer() async {
    server = Server(
      onError: onError,
      onData: onData,
    );
    await server?.start();
  }

  onData(Uint8List data) {
    serverLogs.add(String.fromCharCodes(data));
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  void _connectToPrinter() async {
    try {
      final resultprinter = await connectToPrinter.connectToPrinter();

      if (resultprinter != null) {
        print('resultprinter: $resultprinter');
        if (resultprinter) {
        } else {
          ArtDialogResponse response = await ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Can't connect to printer",
                  text: "Open Bluetooth to automatically connect"));
          print('response: $response');
          if (response.isTapConfirmButton) {
            _connectToPrinter();
          }
        }
      } else {
        ArtDialogResponse response = await ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Can't connect to printer",
                text: "Open Bluetooth to automatically connect"));
        print('else resultprinter: $resultprinter');
        print('response: $response');
        if (response.isTapConfirmButton) {
          _connectToPrinter();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controllerQR = controller;

    controller.scannedDataStream.listen((scanData) async {
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
              barrierDismissible: false,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "SUCCESS!",
                  confirmButtonText: "THANK YOU",
                  onConfirm: () {},
                  text: "qrcode data: ${scanData.code}"));

          if (mounted) {
            await Future.delayed(
                Duration(
                  seconds: 2,
                ), () {
              Navigator.of(context).pop();
              setState(() {
                isQrdetected = false;
              });
            });
          }
        }
      }
    });
  }

  Future<void> _getIPAddress() async {
    String tempIP = await ipAddressService.getIpAddress();

    setState(() {
      ipAddress = tempIP;
    });

    print('ip address: $ipAddress');
  }

  Future<void> _initNFC() async {
    await _getIPAddress();
    // Start continuous scanning
    print('init nfc');
    if (ipAddress.isEmpty || server!.sockets.isEmpty) {
      print('Unable to use this device, no other device are connected!');
      myModal.notAvailableModal(context, "THERE IS NO DEVICE CONNECTED");
      NfcManager.instance.stopSession();
    } else {
      print('nfc dito eee');
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print('${tag.data}');
          // Do something with an NfcTag instance.
          String tagId = nfcbackend.extractTagId(tag);
          setState(() {
            print('main to');
            // _tagId = "tag.data: $tagId";
            _tagId = tagId;
            server!.broadCast({"cardId": "$_tagId"});
            // controller.text = "";
            print('tagid: $_tagId');
          });
        },
      );
    }
    //   // Start continuous scanning
    //   print('init nfc');

    //   // Start Session
    //   NfcManager.instance.startSession(
    //     onDiscovered: (NfcTag tag) async {
    //       print('${tag.data}');
    //       // Do something with an NfcTag instance.
    //       String tagId = nfcbackend.extractTagId(tag);
    //       print('tagid: $tagId');
    //       myModal.costSummary(context, () async {
    //         bool isprint = await printServices.sample();

    //         if (!isprint) {
    //           myModal.errorModal(context,
    //               "SOMETHING WENT WRONG IN PRINTER, PLEASE CONNECT FIRST");
    //         } else {
    //           print('success');
    //           Navigator.of(context).pop();
    //         }
    //       });
    //       // setState(() {
    //       //   print('main to');
    //       //   // _tagId = "tag.data: $tagId";

    //       //   // client!.write({"cardId": "$_tagId", "amount": 100});
    //       //   // messageController.text = "";
    //       //   print('tagid: $tagId');
    //       // });
    //     },
    //   );
  }

  Future<void> _refresh() async {
    // Simulating a time-consuming task
    NfcManager.instance.stopSession();
    // firebaseRDB();
    _initNFC();
    // startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // logic
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            "SAN PEDRO",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.040,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromRGBO(134, 188, 227, 1.0),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Stack(
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 55,
                  margin: const EdgeInsets.only(
                      left: 10), // Adjust the margin as needed
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "10",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.030,
                        ),
                      ),
                      Text(
                        "Pass\nCount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.020,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              width: 60,
              height: 60,
              child: IconButton(
                icon: Image.asset('assets/logout-home.png'),
                onPressed: () {
                  myModal.logout(context);
                },
              ),
            ),
          ],
        ),
        body: Container(
          child: Stack(
            children: [
              // SizedBox(
              //   height: MediaQuery.of(context).size.height,
              //   child: Stack(
              //     children: [
              //       Container(
              //         height: MediaQuery.of(context).size.height,
              //         width: double.infinity,
              //         child: QRView(
              //           overlay: QrScannerOverlayShape(
              //               //customizing scan area
              //               borderWidth: 10,
              //               borderColor: Color.fromARGB(255, 0, 91, 165),
              //               borderLength: 15,
              //               borderRadius: 10,
              //               cutOutSize: MediaQuery.of(context).size.width * 0.7,
              //               overlayColor: Colors.blue.withOpacity(0.5)),
              //           key: qrKey,
              //           onQRViewCreated: _onQRViewCreated,
              //         ),
              //       ),
              //       Align(
              //         alignment: Alignment.bottomCenter,
              //         child: Padding(
              //           padding: const EdgeInsets.only(
              //               bottom: 16.0, left: 8, right: 8),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //             children: [
              //               Expanded(
              //                   flex: 1,
              //                   child: darkblueButton(
              //                       thisFunction: () {
              //                         setState(() {
              //                           isOpenQr = false;
              //                         });
              //                       },
              //                       label: "CLOSE")),
              //               SizedBox(
              //                 width: 10,
              //               ),
              //               Expanded(
              //                 flex: 1,
              //                 child: darkblueButton(
              //                   thisFunction: () async {
              //                     await controllerQR?.toggleFlash();
              //                   },
              //                   label: "FLASH",
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              if (!isOpenQr)
                Stack(children: [
                  Background(),
                  RefreshIndicator(
                    onRefresh: _refresh,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: SingleChildScrollView(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.87,
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black, // Border color
                                          width: 2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text("SUCAT - ALABANG",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        tapCount++;
                                        if (tapCount == 8) {
                                          print('timerss $tapCount');
                                          tapCount = 0;
                                          tapResetTimer?.cancel();
                                          ArtSweetAlert.show(
                                              context: context,
                                              barrierDismissible: false,
                                              artDialogArgs: ArtDialogArgs(
                                                  type: ArtSweetAlertType
                                                      .question,
                                                  showCancelBtn: true,
                                                  confirmButtonText: 'YES',
                                                  cancelButtonText: 'NO',
                                                  title: "SETTINGS",
                                                  onConfirm: () {
                                                    _speak('OPENING SETTINGS!');
                                                    // NfcManager.instance.stopSession();
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SettingsPage()));
                                                  },
                                                  onCancel: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  text: "OPEN SETTINGS?"));
                                        } else {
                                          // Start or reset the tap reset timer
                                          print('timerss $tapCount');
                                          tapResetTimer?.cancel();
                                          tapResetTimer =
                                              Timer(Duration(seconds: 1), () {
                                            tapCount = 0;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(
                                                180, 224, 237, 1.0),
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  82, 161, 217, 1.0),
                                              width: 8,
                                            )),
                                        child: const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Image(
                                            image: AssetImage(
                                                'assets/card-payment.png'),
                                            width: 180,
                                            height: 180,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(
                                              'assets/filipaywoman.png'),
                                          width: 110,
                                          height: 110,
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(top: 25.0),
                                              child: Text(
                                                'TAP YOUR NFC CARD',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              myModal.qrSelect(context, () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  isOpenQr = true;
                                                });
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      180, 224, 237, 1.0),
                                                  border: Border.all(
                                                    color: Color.fromRGBO(
                                                        82, 161, 217, 1.0),
                                                    width: 3,
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: const Image(
                                                  image: AssetImage(
                                                      'assets/qr-code-scan.png'),
                                                  width: 45,
                                                  height: 45,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              myModal.confirmationModal(context,
                                                  "Are you sure you want to re-fetch the data?",
                                                  () async {
                                                // yes function
                                                Navigator.of(context).pop();
                                                myModal.showLoading(
                                                    context, "fetching");
                                                await Future.delayed(
                                                    Duration(
                                                      seconds: 2,
                                                    ), () {
                                                  Navigator.of(context).pop();
                                                });
                                              }, () {
                                                // cancel function
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      180, 224, 237, 1.0),
                                                  border: Border.all(
                                                    color: Color.fromRGBO(
                                                        82, 161, 217, 1.0),
                                                    width: 3,
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Image(
                                                  image: AssetImage(
                                                      'assets/reload.png'),
                                                  width: 45,
                                                  height: 45,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Center(
                  //   child: _isLoading
                  //     ? widget.routePageLoad
                  //       ? myModal.buildRoutePageLoadingModal(context)
                  //       : widget.qrScanLoad
                  //         ? myModal.buildQRScanLoadingModal(context)
                  //         : SizedBox() // Default case if neither routePageLoad nor qrScanLoad is true
                  //     : SizedBox(), // If not loading, show an empty SizedBox
                  // ),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}
