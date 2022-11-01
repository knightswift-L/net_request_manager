library net_request_manager;

import 'package:dio/dio.dart';
import 'package:net_request_manager/model/authenticate_error.dart';

class AuthenticationErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err is AuthenticationError) {
      handler.reject(err);
    } else {
      handler.next(err);
    }
  }
}
