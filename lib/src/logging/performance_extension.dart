import 'dart:collection';
import 'dart:developer' as dev;

import 'package:cancellation_token_http/http.dart' as http;
import 'package:http_extensions/http_extensions.dart';
import 'package:http_extensions_log/http_extensions_log.dart';
import 'package:logging/logging.dart';

class PerformanceExtension extends Extension<LogOptions> {
  final Logger? logger;

  PerformanceExtension({super.defaultOptions = const LogOptions(), this.logger});

  void log(String message, LogOptions options, {Level? level}) {
    if (logger != null) {
      logger!.log(level ?? options.level, message);
    } else {
      dev.log(message, level: Level.FINER.value);
    }
  }

  int _id = 0;
  HashMap<int, int> requestTimestamps = HashMap();

  String _formatPerformance(int id, http.StreamedResponse response) {
    final requestLog = StringBuffer();

    var requestTimestamp = requestTimestamps[id];
    var responseTimestamp = DateTime.now().millisecondsSinceEpoch;

    requestLog.writeln('Performance report for REQ($id) [ ${response.request!.method} | ${response.request!.url}]');
    if (requestTimestamp == null) {
      requestLog.writeln('  * Request data lost');
    } else {
      requestLog.writeln('  * duration: ${responseTimestamp - requestTimestamp} ms');
    }

    requestTimestamps.remove(id);

    return requestLog.toString();
  }

  String _formatError(int id, http.BaseRequest request, dynamic error, StackTrace stackTrace) {
    final errorLog = StringBuffer();

    var requestTimestamp = requestTimestamps[id];
    var responseTimestamp = DateTime.now().millisecondsSinceEpoch;

    errorLog.writeln('Performance report for failed REQ($id) [ ${request.method} | ${request.url} ]');
    if (requestTimestamp == null) {
      errorLog.writeln('  * Request data lost');
    } else {
      errorLog.writeln('  * duration: ${responseTimestamp - requestTimestamp} ms');
    }

    requestTimestamps.remove(id);

    return errorLog.toString();
  }

  @override
  Future<http.StreamedResponse> sendWithOptions(http.BaseRequest request, LogOptions options, { http.CancellationToken? cancellationToken}) async {
    if (!options.isEnabled) {
      return await super.sendWithOptions(request, options, cancellationToken: cancellationToken);
    }

    final id = _id++;

    if (options.logRequestContent) {
      request = BufferedRequest(request);
    }

    requestTimestamps[id] = DateTime.now().millisecondsSinceEpoch;

    try {
      log('Performance report start REQ($id) [ ${request.method} | ${request.url}]', options);
      var response = await super.sendWithOptions(request, options);

      if (options.logResponseContent) {
        response = BufferedStreamResponse(response);
      }

      log('Performance report end REQ($id) [ ${request.method} | ${request.url}]', options);
      log(_formatPerformance(id, response), options);

      return response;
    } catch (error, stacktrace) {
      log('Performance report end REQ($id) [ ${request.method} | ${request.url}]', options);
      log(_formatError(id, request, error, stacktrace), options, level: Level.SEVERE);
      rethrow;
    }
  }
}
