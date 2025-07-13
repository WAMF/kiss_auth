/// Abstract representation of authentication data
abstract class AuthenticationData {
  /// User ID extracted from authentication source
  String get userId;

  /// Raw claims map from authentication source
  Map<String, dynamic> get claims;
}
