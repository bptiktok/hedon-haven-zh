class ScrapingException implements Exception {
  final String message;

  final bool isCritical;

  ScrapingException(
      [this.message = "未知的抓取异常", this.isCritical = false]);

  @override
  String toString() => message;

  Map<String, dynamic> toMap() =>
      {"message": message, "isCritical": isCritical};

  static ScrapingException fromMap(Map<String, dynamic> map) =>
      ScrapingException(map["message"], map["isCritical"] == true);
}

abstract class CustomException implements Exception {
  /// short label to display as title to user
  String get title;

  /// the long exception message that can be overridden at creation
  @override
  String toString() => message;
  final String message;

  String toJson() => message;

  CustomException(this.message);
}

class NoInternetConnectionException extends CustomException {
  NoInternetConnectionException(
      [super.message =
          "应用无法访问互联网，请检查网络连接！"]);

  @override
  String get title => "无网络连接";
}

class AgeGateException extends CustomException {
  AgeGateException(
      [super.message = "此插件在您所在的国家/地区需要年龄验证。"
          "请尝试在设置中设置代理或使用 VPN 服务。"]);

  @override
  String get title => "检测到年龄限制";
}

class BannedCountryException extends CustomException {
  BannedCountryException(
      [super.message = "此插件在您所在的国家/地区不可用。"
          "请尝试在设置中设置代理或使用 VPN 服务。"]);

  @override
  String get title => "检测到受限地区";
}

class UnreachableException extends CustomException {
  UnreachableException(
      [super.message = "无法连接到提供方，请稍后重试。"]);

  @override
  String get title => "无法连接提供方";
}

class NotFoundException extends CustomException {
  NotFoundException(
      [super.message = "未找到所请求的内容（软错误 404）"]);

  @override
  String get title => "未找到";
}

class PrivateAuthorProfileException extends CustomException {
  PrivateAuthorProfileException(
      [super.message = "作者资料为私密状态，禁止访问。"]);

  @override
  String get title => "私密资料";
}

class VirtualRealityNotSupportedException extends CustomException {
  VirtualRealityNotSupportedException(
      [super.message = "尚不支持虚拟现实视频"]);

  @override
  String get title => "不支持 VR";
}

class PluginTimeoutException extends CustomException {
  PluginTimeoutException(
      [super.message = "插件执行功能时超时"]);

  @override
  String get title => "插件超时";
}

/// Map String -> CustomException
final List<CustomException Function(String)> _knownExceptionTypes = [
  NoInternetConnectionException.new,
  AgeGateException.new,
  BannedCountryException.new,
  UnreachableException.new,
  NotFoundException.new,
  PrivateAuthorProfileException.new,
  VirtualRealityNotSupportedException.new,
  PluginTimeoutException.new,
];

/// Converts any thrown object (Exception, Error, ...) to a serializable Map
Map<String, dynamic> convertErrorToMap(Object error) {
  return {
    "type": error.runtimeType.toString(),
    // Strip the "...Exception: " / "...Error: " prefix, since the type is
    // prepended again in convertMapToException
    "message":
        error.toString().replaceFirst(RegExp(r"^\w*(Exception|Error): "), "")
  };
}

/// Reconstructs whatever convertErrorToMap produced: the real
/// CustomException subtype if map["type"] matches one of the known types,
/// or a plain Exception otherwise, with the original runtime type prepended
/// to the message
Exception convertMapToException(Map<String, dynamic> map) {
  for (final constructor in _knownExceptionTypes) {
    final instance = constructor(map["message"]);
    if (instance.runtimeType.toString() == map["type"]) return instance;
  }
  return Exception("${map["type"]}: ${map["message"]}");
}
