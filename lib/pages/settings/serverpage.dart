import 'dart:typed_data';

import 'package:filipay/class/server.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServerPage extends StatefulWidget {
  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  Server? server;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();
  bool serverstatus = false;

  @override
  void initState() {
    server = Server(
      onData: onData,
      onError: onError,
    );
    _startServer();

    super.initState();
  }

  Future<void> _startServer() async {
    if (server != null && !(server!.running)) {
      await server!.start();
    } else if (server != null && server!.running) {
      await server!.stop();
      await server!.start();
    }
  }

  onData(Uint8List data) {
    serverLogs.add(String.fromCharCodes(data));
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  // dispose() {
  //   controller.dispose();
  //   server?.stop();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(134, 188, 227, 1.0),
        title: Text(
          'Server',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Server",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: server!.running ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(
                          server!.running ? 'ON' : 'OFF',
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
                      if (server!.running) {
                        await server!.stop();
                        this.serverLogs.clear();
                      } else {
                        await server!.start();
                      }
                      setState(() {});
                    },
                    child: Text(server!.running
                        ? 'Stop the server'
                        : 'Start the server'),
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
          Container(
            color: Colors.grey,
            height: 80,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 33, 149, 243),
                      borderRadius: BorderRadius.circular(100)),
                  child: MaterialButton(
                    onPressed: () {
                      server!.broadCast({"message": "test"});
                      controller.text = "";
                    },
                    minWidth: 30,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Icon(Icons.send),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
