import 'package:dio/dio.dart';

class AuthenticationError extends DioError {
  AuthenticationError({required super.requestOptions});
}
