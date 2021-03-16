import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

mixin ClipboardManager on ValueNotifier<TextEditingValue> {
  /// If text selected then cut selected text [implicitly by flutter]
  /// If text is not selected cut all line
  void cutText() {
    if (value.selection.isCollapsed && value.text.isNotEmpty) {
      final rawText = value.text;
      var cursorIndex =
          value.selection.baseOffset < 0 ? 0 : value.selection.baseOffset;
      // if cursor at the end of the text
      if (rawText.length == cursorIndex) {
        if (rawText[cursorIndex - 1] == '\n') {
          value = TextEditingValue(
            text: rawText.substring(0, cursorIndex - 1),
            selection: TextSelection(
              extentOffset: cursorIndex - 1,
              baseOffset: cursorIndex - 1,
            ),
          );
          Clipboard.setData(const ClipboardData(text: '\n'));
          return;
        } else {
          cursorIndex--;
        }
      }

      // if cursor at the end of the line
      if (rawText[cursorIndex] == '\n') {
        // if cursor at the start of the line and line is empty
        if (cursorIndex == 0) {
          Clipboard.setData(const ClipboardData(text: '\n'));
          value = value.copyWith(text: rawText.substring(1));
          return;
        }
        // if line is empty
        else if (rawText[cursorIndex - 1] == '\n') {
          value = TextEditingValue(
            text: "${rawText.substring(0, cursorIndex)}"
                "${rawText.substring(cursorIndex + 1)}",
            selection: TextSelection(
              baseOffset: cursorIndex - 1,
              extentOffset: cursorIndex - 1,
            ),
          );
          Clipboard.setData(const ClipboardData(text: '\n'));
          return;
        }
        // if cursor at the end of the line but line is not empty
        else {
          cursorIndex--;
        }
      }
      var beforeCursor = cursorIndex;
      var afterCursor = cursorIndex;
      for (;
          beforeCursor != 0 && rawText[beforeCursor] != '\n';
          beforeCursor--) {}
      for (;
          afterCursor != rawText.length && rawText[afterCursor] != '\n';
          afterCursor++) {}
      final line = rawText.substring(beforeCursor, afterCursor);

      Clipboard.setData(ClipboardData(text: line));
      value = TextEditingValue(
        text: "${rawText.substring(0, beforeCursor)}"
            "${rawText.substring(afterCursor)}",
        selection: TextSelection(
          baseOffset: beforeCursor,
          extentOffset: beforeCursor,
        ),
      );
    }
  }

  /// If text selected then copy selected text [implicitly by flutter]
  /// If text is not selected copy all line
  void copyText() {
    if (value.selection.isCollapsed && value.text.isNotEmpty) {
      final rawText = value.text;
      var cursorIndex =
          value.selection.baseOffset < 0 ? 0 : value.selection.baseOffset;

      // if cursor at the end of the text
      if (rawText.length == cursorIndex) {
        if (rawText[cursorIndex - 1] == '\n') {
          Clipboard.setData(const ClipboardData(text: '\n'));
          return;
        } else {
          cursorIndex--;
        }
      }

      // if cursor at the end of the line
      if (rawText[cursorIndex] == '\n') {
        // if cursor at the start of the line and line is empty
        if (cursorIndex == 0) {
          Clipboard.setData(const ClipboardData(text: '\n'));
          return;
        }
        // if line is empty
        else if (rawText[cursorIndex - 1] == '\n') {
          Clipboard.setData(const ClipboardData(text: '\n'));
          return;
        }
        // if cursor at the end of the line but line is not empty
        else {
          cursorIndex--;
        }
      }

      var beforeCursor = cursorIndex;
      var afterCursor = cursorIndex;
      for (;
          beforeCursor != 0 && rawText[beforeCursor] != '\n';
          beforeCursor--) {}
      for (;
          afterCursor != rawText.length && rawText[afterCursor] != '\n';
          afterCursor++) {}
      final line = "\n${rawText.substring(beforeCursor++, afterCursor)}\n";

      Clipboard.setData(ClipboardData(text: line));
      value = value.copyWith(
          selection: TextSelection(
        baseOffset: beforeCursor - 1,
        extentOffset: afterCursor,
      ));
    }
  }
}
