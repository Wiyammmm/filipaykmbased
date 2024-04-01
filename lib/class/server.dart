import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

import 'package:filipay/services/nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';

typedef Uint8ListCallback = void Function(Uint8List data);
typedef DynamicCallback = void Function(dynamic error);

class Server {
  final Uint8ListCallback onData;
  final DynamicCallback onError;
  late ServerSocket server;
  Server({required this.onError, required this.onData});

  // ServerSocket server;
  bool running = false;
  List<Socket> sockets = [];

  nfcBackend nfcbackend = nfcBackend();

  start() async {
    runZoned(() async {
      server = await ServerSocket.bind('0.0.0.0', 4040, shared: true);
      running = true;
      server.listen(onRequest);
      onData(Uint8List.fromList('Server listening on port 4040'.codeUnits));
    }, onError: (e) {
      onError(e);
    });
  }

  stop() async {
    await server.close();

    running = false;
    sockets.clear();
  }

  broadCast(Map<String, dynamic> message) {
    onData(Uint8List.fromList('$message'.codeUnits));

    print('socketsbroad: $sockets');

    for (Socket socket in sockets) {
      socket.write(message);
    }
  }

  onRequest(Socket socket) {
    print('socket server class: $socket');
    print('socket server list: $sockets');

    if (!sockets.contains(socket)) {
      sockets.add(socket);

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print('${tag.data}');
          // Do something with an NfcTag instance.
          String tagId = nfcbackend.extractTagId(tag);

          onData(Uint8List.fromList('{"cardId": "$tagId"}'.codeUnits));

          socket.write({"cardId": "$tagId"});
        },
      );
    }
    socket.listen((Uint8List data) {
      onData(data);
    }, onDone: () {
      print('Socket disconnected: $socket');
      sockets.remove(socket);

      NfcManager.instance.stopSession();
    });
  }
}
