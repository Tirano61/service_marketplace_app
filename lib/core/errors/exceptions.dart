class ServerException implements Exception {
  const ServerException([this.message]);

  final String? message;
}

class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;
}
class EmailVerificationPendingException implements Exception {
  const EmailVerificationPendingException({
    this.message,
    this.email,
  });

  final String? message;
  final String? email;
}