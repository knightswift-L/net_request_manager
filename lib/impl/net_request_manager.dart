library net_request_manager;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_request_manager/interface/net_request_manager_interface.dart';
import 'package:net_request_manager/model/cresponse.dart';
import 'package:net_request_manager/util/balancer_manager.dart';

class NetRequestManager extends NetRequestManagerInterface {
  NetRequestManager._privateConstructor();
  static final NetRequestManager _instance = NetRequestManager._privateConstructor();
  static NetRequestManager get instance => _instance;
  Map<String, dynamic> _headers = {};

  @override
  Map<String, dynamic>? getHeader() {
    return _headers;
  }

  void updateHeader(Map<String, dynamic> headers) {
    _headers = headers;
  }

  @override
  Future<CResponse> downloadFile(String url, {UpdateProgress? downLoadProgress, CancelToken? token}) async {
    var response = await dio.download(url, "", onReceiveProgress: (int count, int total) {
      downLoadProgress?.call(count / total);
    });
    return await processResponse(response);
  }

  @override
  Future<CResponse<T?>> get<T>(String url, {String? baseUrl, Map<String, dynamic>? queryParameters, CancelToken? token, ToBean? toBean}) async {
    var response = await dio.get(url, queryParameters: queryParameters ?? {});
    return await processResponse<T>(response, toBean: toBean);
  }

  @override
  Future<CResponse<T?>> post<T>(String url, {String? baseUrl, Map<String, dynamic>? data, CancelToken? token, ToBean? toBean}) async {
    var response = await dio.post(url, data: data);
    return await processResponse<T>(response, toBean: toBean);
  }

  @override
  Future<CResponse> uploadFiles(String url, {required FormData data, UpdateProgress? uploadProgress, CancelToken? token}) async {
    var response = await dio.post(url, data: data, onSendProgress: (int count, int total) {
      uploadProgress?.call(count / total);
    });
    return await processResponse(response);
  }

  Future<CResponse<T>> processResponse<T>(Response response, {ToBean? toBean}) async {
    if (toBean == null) {
      return response.data;
    }
    if (response.data is CResponse) {
      var data = await balancerExecute<T, Map<String, dynamic>?>((Map<String, dynamic>? json) => toBean(json), response.data.data);
      return CResponse(code: response.data.code, message: response.data.message, data: data);
    } else if (response.data.data is Map<String, dynamic>) {
      var data = await balancerExecute<T, Map<String, dynamic>?>((Map<String, dynamic>? json) => toBean(json), response.data);
      return CResponse(code: response.data.code, message: response.data.message, data: data);
    } else if (response.data is String) {
      try {
        Map<String, dynamic>? map = json.decode(response.data.data);
        var data = await balancerExecute<T, Map<String, dynamic>?>((Map<String, dynamic>? json) => toBean(json), map);
        return CResponse(code: response.data.code, message: response.data.message, data: data);
      } catch (e) {
        return CResponse(
          code: -1,
          message: DioErrorType.other.name,
          data: null,
        );
      }
    }
    return CResponse(
      code: -1,
      message: "Undefined Error",
      data: null,
    );
  }
}
