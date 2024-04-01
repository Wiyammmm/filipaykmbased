import 'dart:async';

import 'package:filipay/pages/test.dart';
import 'package:filipay/widgets/modals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'route_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MyModal mymodals = MyModal();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/bg-red-blue.png')),
            Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset('assets/citybg.png')),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                child: Image.asset('assets/filipay-logo-w-name.png'),
              ),
              Container(
                  child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Mobile Number"),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a valid mobile number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0), // Adjust the value as needed
                                    ),
                                  )),
                            ),
                            Text("Password"),
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
                                      borderRadius: BorderRadius.circular(
                                          20.0), // Adjust the value as needed
                                    ),
                                  )),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(50.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        mymodals.showLoading(
                                            context, "fetching");

                                        Timer(Duration(seconds: 3), () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SelectRoutePage()),
                                          );
                                        });
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => SelectRoutePage()),
                                        // );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(135, 189, 230, 1.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Rounded corners
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      elevation: 5, // Padding
                                      textStyle: const TextStyle(
                                          fontSize: 16.0), // Text style
                                    ),
                                    child: const Text(
                                      'LOG IN',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),
            ]),
          ]),
        ),
      ),
    );
  }
}
