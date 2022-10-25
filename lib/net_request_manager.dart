library net_request_manager;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

typedef UpdateProgress = void Function(double progress);

abstract class NetRequestManagerInterface {
  late Dio _dio;
  void _init({required String host, required int connectTimeout, required int receiveTimeout, required int sendTimeout}) {
    _dio = Dio(BaseOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      baseUrl: host,
    ));
    // (_dio as DioForNative).jsonDecodeCallback = _parseAndDecode;
  }

  void init({required String host, int connectTimeout = 20000, int receiveTimeout = 20000, int sendTimeout = 20000}) {
    _init(host: host, connectTimeout: connectTimeout, receiveTimeout: receiveTimeout, sendTimeout: sendTimeout);
  }

  void updateHost(String host) {
    _dio.options.baseUrl = host;
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<CResponse> get(String url, {String? baseUrl, Map<String, dynamic>? queryParameters, CancelToken? token});
  Future<CResponse> post(String url, {String? baseUrl, Map<String, dynamic>? data, CancelToken? token});
  Future<CResponse> downloadFile(String url, {UpdateProgress? downLoadProgress, CancelToken? token});
  Future<CResponse> uploadFiles(String url, {required FormData data, UpdateProgress? uploadProgress, CancelToken? token});
}

class CResponse<T> {
  int? status;
  bool isSuccess;
  T? data;
  CResponse({
    this.status,
    this.isSuccess = false,
    this.data,
  });
}

class NetRequestManager extends NetRequestManagerInterface {
  NetRequestManager._privateConstructor();
  static final NetRequestManager _instance = NetRequestManager._privateConstructor();
  static NetRequestManager get instance  => _instance;
  @override
  Future<CResponse> downloadFile(String url, {UpdateProgress? downLoadProgress, CancelToken? token}) async {
    var response = await _dio.download(url, "", onReceiveProgress: (int count, int total) {
      downLoadProgress?.call(count / total);
    });
    return _processResponse(response);
  }

  @override
  Future<CResponse> get(String url, {String? baseUrl, Map<String, dynamic>? queryParameters, CancelToken? token}) async {
    var response = await _dio.get(url, queryParameters: queryParameters ?? {});
    return _processResponse(response);
  }

  @override
  Future<CResponse> post(String url, {String? baseUrl, Map<String, dynamic>? data, CancelToken? token}) async {
    var response = await _dio.post(url, data: data);
    return _processResponse(response);
  }

  @override
  Future<CResponse> uploadFiles(String url, {required FormData data, UpdateProgress? uploadProgress, CancelToken? token}) async {
    var response = await _dio.post(url, data: data, onSendProgress: (int count, int total) {
      uploadProgress?.call(count / total);
    });
    return _processResponse(response);
  }

  CResponse _processResponse(Response response) {
    if (response.statusCode == 200) {
        return CResponse(status: response.statusCode, isSuccess: true, data: response.data);
    }
    return CResponse(status: response.statusCode, isSuccess: false, data: null);
  }
}

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Map<String, dynamic> temp = options.headers;
    temp["Authorization"] = "";
    options.headers = temp;
    handler.next(options);
  }
}

class AuthenticationError extends DioError{
  AuthenticationError({required super.requestOptions});

}


class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}


class AuthenticationErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if(err is AuthenticationError){
        /// 认证失败处理逻辑
    }else{
      handler.next(err);
    }
  }
}


class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if(kDebugMode){
      print("Url:${options.baseUrl}${options.path}");
      for(var key in options.headers.keys){
        print("$key:${options.headers[key]}");
      }
      print("parameters:${options.method.toUpperCase() == "Get" ? options.queryParameters : options.data}");

    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if(kDebugMode){
      print("Url:${response.requestOptions.baseUrl}${response.requestOptions.path}");
      print("Status:${response.statusCode}");
      print("response:${response.data}");
    }
   handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
     handler.next(err);
  }
}