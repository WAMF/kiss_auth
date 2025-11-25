import 'package:meta/meta.dart';

/// Result of a password reset request
@immutable
class PasswordResetResult {
  /// Creates a password reset result
  const PasswordResetResult({
    required this.isSuccess,
    this.message,
    this.error,
    this.errorCode,
  });

  /// Creates a successful password reset result
  factory PasswordResetResult.success({String? message}) {
    return PasswordResetResult(
      isSuccess: true,
      message: message,
    );
  }

  /// Creates a failed password reset result
  factory PasswordResetResult.failure({
    required String error,
    String? errorCode,
  }) {
    return PasswordResetResult(
      isSuccess: false,
      error: error,
      errorCode: errorCode,
    );
  }

  /// Whether the password reset request was successful
  final bool isSuccess;

  /// Success message (if applicable)
  final String? message;

  /// Error message (if failed)
  final String? error;

  /// Error code for programmatic handling (if failed)
  final String? errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordResetResult &&
          runtimeType == other.runtimeType &&
          isSuccess == other.isSuccess &&
          message == other.message &&
          error == other.error &&
          errorCode == other.errorCode;

  @override
  int get hashCode =>
      isSuccess.hashCode ^
      message.hashCode ^
      error.hashCode ^
      errorCode.hashCode;

  @override
  String toString() {
    if (isSuccess) {
      return 'PasswordResetResult.success(message: $message)';
    }
    return 'PasswordResetResult.failure(error: $error, code: $errorCode)';
  }
}
