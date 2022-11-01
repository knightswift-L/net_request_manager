library net_request_manager;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:net_request_manager/interceptor/authentication_interceptor.dart';
import 'package:net_request_manager/interceptor/header_interceptor.dart';
import 'package:net_request_manager/interceptor/log_interceptor.dart';
import 'package:net_request_manager/interceptor/response_interceptor.dart';
import 'package:net_request_manager/net_request_manager.dart';

typedef UpdateProgress = void Function(double progress);
typedef ToBean = Function(Map<String, dynamic>?);

abstract class NetRequestManagerInterface {
  late Dio dio;
  late LogLevel level;
  void _init({
    required String host,
    required int connectTimeout,
    required int receiveTimeout,
    required int sendTimeout,
    LogLevel logLevel = LogLevel.Debug,
  }) {
    level = logLevel;
    dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        baseUrl: host,
      ),
    );
    _addDefaultInterceptors();
  }

  void init({required String host, int connectTimeout = 20000, int receiveTimeout = 20000, int sendTimeout = 20000}) {
    _init(host: host, connectTimeout: connectTimeout, receiveTimeout: receiveTimeout, sendTimeout: sendTimeout);
  }

  void updateHost(String host) {
    dio.options.baseUrl = host;
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  void _addDefaultInterceptors() {
    dio.interceptors.add(HeaderInterceptor(getHeader));
    dio.interceptors.add(CLogInterceptor());
    dio.interceptors.add(ResponseInterceptor());
    dio.interceptors.add(AuthenticationErrorInterceptor());
  }

  Map<String, dynamic>? getHeader() => null;

  Future<CResponse<T?>> get<T>(String url, {String? baseUrl, Map<String, dynamic>? queryParameters, CancelToken? token, ToBean? toBean});
  Future<CResponse<T?>> post<T>(String url, {String? baseUrl, Map<String, dynamic>? data, CancelToken? token, ToBean? toBean});
  Future<CResponse> downloadFile(String url, {UpdateProgress? downLoadProgress, CancelToken? token});
  Future<CResponse> uploadFiles(String url, {required FormData data, UpdateProgress? uploadProgress, CancelToken? token});
}
