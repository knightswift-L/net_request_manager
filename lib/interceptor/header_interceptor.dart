library net_request_manager;

import 'package:dio/dio.dart';

typedef GetOptionalParameters = Map<String, dynamic>? Function();

class HeaderInterceptor extends Interceptor {
  final GetOptionalParameters getParameters;

  HeaderInterceptor(this.getParameters);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Map<String, dynamic> temp = options.headers;
    options.responseType = ResponseType.json;
    var parameters = getParameters();
    if (parameters != null) {
      temp.addAll(parameters);
    }
    options.headers = temp;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
