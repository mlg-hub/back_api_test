import 'dart:io';

import 'package:hive/hive.dart';
import 'package:mados_group/models/idea.dart';
import 'package:mados_group/models/user.dart';
import 'package:mados_group/routes/api.dart';
import 'package:mados_group/server.dart';

// part 'main.g.dart';

void main() async {
  var path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter(UserAdapter())
    ..registerAdapter(IdeaAdapter());

  print("Enter the ip du serveur: ");
  String? localhost = "192.168.1.13" ?? stdin.readLineSync();

  try {
    final apiRequest = Api();
    final appServer = AppServer(
        hostname: InternetAddress(localhost ?? "0.0.0.0"),
        apiRequest: apiRequest);
    appServer.startServer();
  } catch (e) {
    print("could not start the server");
  }
}
