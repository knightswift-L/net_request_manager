library net_request_manager;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("=============请求开始=============");
    print("Url:${options.baseUrl}${options.path}");
    print("Method:${options.method.toUpperCase()}");
    for (var key in options.headers.keys) {
      print("$key:${options.headers[key]}");
    }
    print("parameters:${options.method.toUpperCase() == "Get" ? options.queryParameters : options.data}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("=============请求结束=============");
    print("Url:${response.requestOptions.baseUrl}${response.requestOptions.path}");
    print("Status:${response.statusCode}");
    print("response:${response.data}");
    var data = (response.data?.toString() ?? "");
    print("response:");
    int length = (data.length / 400).ceil();

    for (int index = 0; index < length; index++) {
      print(data.substring(400 * index, 400 * (index + 1) > data.length ? data.length : 400 * (index + 1)));
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
