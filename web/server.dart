library server;

import 'dart:io';
import 'dart:isolate';
import 'dart:json';
import 'server-utils.dart';

class jsonDataHandler {

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.outputStream.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request, HttpResponse response) {
    final String path = request.path == '/' ? '/index.html' : request.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(response);
          } else {
            file.openInputStream().pipe(response.outputStream);
          }
        });
      } else {
        _send404(response);
      }
    });
  }
}

class DrawHandler {
  Set<WebSocketConnection> webSocketConnections;

  DrawHandler() : webSocketConnections = new Set<WebSocketConnection>() {
    //init
  }

  // closures!
  onOpen(WebSocketConnection conn) {
    print('new ws conn');
    webSocketConnections.add(conn);

    conn.onClosed = (int status, String reason) {
      print('conn is closed');
      webSocketConnections.remove(conn);
    };
    conn.onMessage = (message) {
      print('new ws msg: $message');
      //spread message on each ws connections
      webSocketConnections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => connection.send(message));
        }
      });
      //store it
      //time('send to isolate', () => log.log(message));
    };
  }
}

runServer(int port) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  
  //@todo init data source
  
  wsHandler.onOpen = new DrawHandler().onOpen;

  server.defaultRequestHandler = new jsonDataHandler().onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', port);
  print('listening for connections on $port');
}

main() {
  var script = new File(new Options().script);
  var directory = script.directorySync();
  runServer(1337); 
}