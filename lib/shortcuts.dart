import 'package:flutter/services.dart';

class ShortcutPredictor {
  ShortcutType match(RawKeyEvent keyEvent) {
    if (keyEvent.isMetaPressed) {
      // undo && restore
      if (keyEvent.physicalKey == PhysicalKeyboardKey.keyZ) {
        if (keyEvent.isShiftPressed) {
          return ShortcutType.restore;
        } else {
          return ShortcutType.undo;
        }
      }

      // copy
      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyC)) {
        return ShortcutType.copy;
      }

      // cut
      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyX)) {
        return ShortcutType.cut;
      }

      // run
      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyR)) {
        return ShortcutType.run;
      }
    }

    return ShortcutType.none;
  }
}

enum ShortcutType {
  /// command + z
  undo,

  /// command + shift + z
  restore,

  /// command + c
  copy,

  /// command + x
  cut,

  /// command + r
  run,

  /// if no shortcut found
  none,
}
