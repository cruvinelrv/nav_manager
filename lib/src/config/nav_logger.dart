class NavLogger {
  final bool enableDebug;
  final Function(String)? customLogger;

  NavLogger({
    this.enableDebug = false,
    this.customLogger,
  });

  void log(String message) {
    if (customLogger != null) {
      customLogger!(message);
    } else if (enableDebug) {
      print(message);
    }
  }

  void logSuccess(String message) {
    log('✅ $message');
  }

  void logError(String message) {
    log('❌ $message');
  }

  void logWarning(String message) {
    log('⚠️  $message');
  }

  void logInfo(String message) {
    log('ℹ️  $message');
  }

  void logProgress(String message) {
    log('⏳ $message');
  }

  void logModule(String message) {
    log('📦 $message');
  }

  void logRoute(String message) {
    log('🛣️  $message');
  }

  void logRemote(String message) {
    log('🌐 $message');
  }

  void logDebug(String message) {
    log('📊 $message');
  }
}
