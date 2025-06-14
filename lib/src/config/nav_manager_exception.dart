class NavManagerException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  NavManagerException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    var result = 'NavManagerException: $message';
    if (originalError != null) {
      result += '\nCaused by: $originalError';
    }
    if (stackTrace != null) {
      result += '\nStackTrace: $stackTrace';
    }
    return result;
  }
}
