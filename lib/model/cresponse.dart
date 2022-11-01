library net_request_manager;

class CResponse<T> {
  int? code;
  T? data;
  String? message;
  String? ts;
  CResponse({this.code, this.data, this.ts, this.message});

  @override
  String toString() {
    return "Status:$code \n IsSuccess:$isSuccess \n Data:$data";
  }

  bool get isSuccess => code == 200;
}

CResponse<T> cResponseFromJson<T>(Map? json) {
  print("==========>${json!["code"].runtimeType}");
  print("==========>${json["msg"].runtimeType}");
  print("==========>${json["ts"].runtimeType}");
  print("==========>${json["data"].runtimeType}");
  return CResponse(
    code: json['code'] as int?,
    message: json['msg'] as String?,
    // ts: json['ts'] as String?,
    data: json['data'],
  );
}
