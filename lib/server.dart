import 'dart:convert';
import 'dart:io';

import '../routes/api.dart';

const client = ClientRequest();

class AppServer {
  HttpServer? server;
  final InternetAddress hostname;
  final Api apiRequest;
  AppServer({required this.hostname, required this.apiRequest});

  startServer() async {
    try {
      server = await HttpServer.bind(hostname, 4040, shared: true);

      server!.listen((request) {
        //debugPrint("new request is here");
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers
            .add('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');
        _handleRequest(request);
      });

      print(
          "Server is listening at port: ${server!.address.host}:${server!.port.toString()}");

      return true;
    } catch (_) {
      return false;
    }
  }

  stopServer() async {
    try {
      if (server != null) {
        await server!.close();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  _handleRequest(HttpRequest request) async {
    print("Request received : ${request.method}");
    switch (request.method) {
      case "POST":
        final r = await client.handleClientPostRequest(request, apiRequest);
        request.response.write(jsonEncode(r));
        request.response.close();
        break;
      case "GET":
        final get = await client.handleClientGetRequest(request, apiRequest);
        request.response.write(jsonEncode(get));
        request.response.close();
        break;
      default:
        request.response.write([]);
        request.response.close();
    }
  }
}

class ClientRequest {
  const ClientRequest();

  Future handleClientGetRequest(HttpRequest request, Api apiRequest) async {
    final map = jsonDecode(await utf8.decoder.bind(request).join());
    print("the map is : $map");
    switch (request.uri.path) {
      case '/ping':

        // return await apiRequest.isAllowed(
        //     map["perms"] ?? "", map["group_id"] ?? "0");
        return [];
      case '/get_feed':
        /*
              {
          "index_min": "0",
          "count": "3"  
      }
      */
        return await apiRequest.get_feed(map);
      case '/search_ideas':
        /*
        {
            "tags": "dance"
        }
      */
        return await apiRequest.search_ideas(map);
      default:
        return 'route not found';
    }
  }

  Future handleClientPostRequest(HttpRequest request, Api apiRequest) async {
    var req;
    try {
      req = jsonDecode(await utf8.decoder.bind(request).join());
    } catch (e) {
      print("error occured $e");
    }
    switch (request.uri.path) {
      case '/logout_user':
        return await apiRequest.logout_user();
      case '/delete_idea':
        return await apiRequest.delete_idea(req);
      case '/like_idea':
        return await apiRequest.like_idea(req);
      case '/comment_idea':
        return await apiRequest.comment_idea(req);
      case '/register_user':
        /*
           {
          "username": "user1",
          "full_name": "my user full_name",
          "telephone": "1234544",
          "password": "345654",
          "address": "kinanira 3"
          }
       */
        return await apiRequest.register_user(req);
      case '/update_profile':
        return await apiRequest.update_profile(req);
      case '/post_ideas':
        /*
        req schema : {
          "username": "string",
          "tags": "tag1,tag2", /list of string'
          "title": "string"
        }
      */
        final res = await apiRequest.post_ideas(req);
        return res;
      case '/login_user':
        /** 
       * req Schema {
       *  "username": "username",
       * "password": "password"
       * }
      */
        return await apiRequest.login_user(req);
      default:
        return 'route not found';
    }
  }
}
