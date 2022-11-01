library net_request_manager;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_request_manager/model/authenticate_error.dart';
import 'package:net_request_manager/model/cresponse.dart';
import 'package:net_request_manager/util/balancer_manager.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 200) {
      var result = await processResponse(response);
      if (result.code == 401) {
        handler.reject(AuthenticationError(requestOptions: response.requestOptions));
      } else {
        response.data = result;
      }
    } else {
      handler.reject(DioError(requestOptions: response.requestOptions));
    }
    handler.next(response);
  }

  Future<CResponse> processResponse(
    Response response,
  ) async {
    if (response.data is Map<String, dynamic>) {
      return await balancerExecute<CResponse, Map<String, dynamic>?>(cResponseFromJson, response.data);
    } else if (response.data is String) {
      try {
        Map<String, dynamic>? map = json.decode(response.data);
        return await balancerExecute<CResponse, Map<String, dynamic>?>(cResponseFromJson, map);
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
      message: DioErrorType.other.name,
      data: null,
    );
  }
}
