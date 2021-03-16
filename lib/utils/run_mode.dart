/// This class helps determine flutter app or dart app
class RunMode {
  RunModeType determineRunMode(String code) {
    return code.contains('package:flutter/')
        ? RunModeType.flutter
        : RunModeType.dart;
  }
}

enum RunModeType { dart, flutter }
