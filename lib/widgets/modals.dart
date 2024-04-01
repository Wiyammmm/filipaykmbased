import 'package:filipay/components/mycolors.dart';

import 'package:filipay/pages/qrcam.dart';
import 'package:filipay/services/getDeviceInfo.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import '../pages/login.dart';

class MyModal {
  final _myBox = Hive.box('myBox');

  void greetings(BuildContext context) {
    double travelledFair = 62.07;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 350,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: AssetImage('assets/filipay-logo.png'),
                  height: 100,
                ),
                Text(
                  'Your Traveled Fare is P${travelledFair}',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'WELCOME!\nHAVE A SAFE RIDE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Image(
                    image: AssetImage('assets/hello.png'),
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void generateQR(BuildContext context) {
    final SESSION = _myBox.get('SESSION');
    String serialNumber = SESSION['sNo'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 370,
            width: 370,
            child: Center(
              child: Stack(children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 110,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset('assets/filipaywoman.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [Colors.red, Colors.blue],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds);
                          },
                          child: Text(
                            "FILIPAY",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Color.fromRGBO(
                                    13, 93, 158, 1.0), // Border color
                                width: 5,
                              ),
                              color: Colors.white,
                            ),
                            child: QrImageView(
                              data:
                                  'https://filipworks.com/qrs2/?sn=$serialNumber&filipay=true',
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(135, 189, 230, 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'SCAN ME!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void qrSelect(BuildContext context, void Function() scanqrcodeFunction) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: Container(
              height: 200,
              width: 800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: scanqrcodeFunction,
                    // () {
                    //   Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => const QRCam(),
                    //   ));
                    // },
                    child: Container(
                      height: 130,
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(135, 189, 230, 1.0),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Image(
                              image: AssetImage('assets/qr-scan.png'),
                              width: 60,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Text(
                              'SCAN QR CODE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.028,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      generateQR(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(135, 189, 230, 1.0),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Image(
                              image: AssetImage('assets/qr-code.png'),
                              width: 60,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Text(
                              'GENERATE QR CODE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.028,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildRoutePageLoadingModal(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.17,
          width: MediaQuery.of(context).size.width * 0.50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image(
                  image: AssetImage('assets/loading.gif'),
                  width: 70,
                ),
              ),
              Text(
                'Fetching Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildQRScanLoadingModal(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.17,
          width: MediaQuery.of(context).size.width * 0.50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image(
                  image: AssetImage('assets/loading.gif'),
                  width: 70,
                ),
              ),
              Text(
                'Processing...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void costSummary(BuildContext context, void Function() thisFunction) {
    double travelledFair = 62.07;
    double refund = -2.07;
    double remainingBalance = 0.00;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.77,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: AssetImage('assets/filipay-logo.png'),
                  width: 100,
                  height: 100,
                ),
                Text(
                  'Your Traveled Fare is P${travelledFair}',
                ),
                Text(
                  'We had refund P${refund}',
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Remaining Balance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.050,
                        ),
                      ),
                    ),
                    Text(
                      'P${remainingBalance}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.050,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color.fromRGBO(217, 217, 217, 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Date & Time"),
                                Text("00/00/2024"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Traveled Distance"),
                                Text("2.07"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Traveled Fare"),
                                Text("62.07"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Plate Number"),
                                Text("N0512"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Refund Amount"),
                                Text("2.07"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: ElevatedButton(
                    onPressed: thisFunction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(135, 189, 230, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 5, // Padding
                      textStyle: const TextStyle(fontSize: 16.0), // Text style
                    ),
                    child: const Text(
                      'PRINT RECEIPT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void logout(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: IntrinsicHeight(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              // height: 500,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(
                          image: AssetImage('assets/filipay-logo.png'),
                          width: 150,
                        ),
                        Text("Enter password to logout",
                            style: TextStyle(
                              fontSize: 14.0,
                            )),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Perform login action
                                if (_formKey.currentState!.validate()) {
                                  ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                      showCancelBtn: true,
                                      type: ArtSweetAlertType.info,
                                      confirmButtonText: "Logout",
                                      title: "Confirm Logout",
                                      text: "Are you sure you want to logout?",
                                      onConfirm: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(135, 189, 230, 1.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 15.0),
                                elevation: 5,
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              child: const Text(
                                'VERIFY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showLoading(BuildContext context, String label) {
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${label.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'assets/loading.gif',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Text(
                      'Please wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void errorModal(BuildContext context, String message) {
    ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.info,
            title: "ERROR",
            text: "${message.toUpperCase()}",
            confirmButtonText: "THANK YOU",
            confirmButtonColor: AppColors.primaryColor));
  }

  void notAvailableModal(BuildContext context, String message) {
    ArtSweetAlert.show(
        context: context,
        barrierDismissible: false,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.info,
            title: "SOMETHING WENT WRONG",
            text: "${message.toUpperCase()}",
            confirmButtonText: "PLEASE CONNECT FIRST",
            onConfirm: () {
              return;
            },
            confirmButtonColor: AppColors.primaryColor));
  }

  void confirmationModal(BuildContext context, String message,
      void Function() yesFunction, void Function() noFunction) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.info,
          title: "CONFIRMATION",
          text: "${message.toUpperCase()}",
          showCancelBtn: true,
          confirmButtonText: "YES",
          cancelButtonText: "NO",
          onConfirm: yesFunction,
          onCancel: noFunction,
          confirmButtonColor: AppColors.primaryColor),
    );
  }
}
