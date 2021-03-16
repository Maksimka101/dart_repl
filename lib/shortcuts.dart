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

      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyC)) {
        return ShortcutType.copy;
      }

      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyX)) {
        return ShortcutType.cut;
      }

      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyR)) {
        return ShortcutType.run;
      }

      if (keyEvent.isAltPressed && keyEvent.isKeyPressed(LogicalKeyboardKey.keyL)) {
        return ShortcutType.reformatCode;
      }
    }

    if (keyEvent.isShiftPressed) {
      if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
        return ShortcutType.jumpToNextLine;
      }
    }

    if (keyEvent.isKeyPressed(LogicalKeyboardKey.tab)) {
      return ShortcutType.tab;
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

  /// shift + return
  jumpToNextLine,

  ///  tab
  tab,

  /// command + option + l
  reformatCode,

  /// if no shortcut found
  none,
}
