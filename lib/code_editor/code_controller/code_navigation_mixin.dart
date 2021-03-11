import 'package:flutter/cupertino.dart';

mixin CodeNavigationManager on ValueNotifier<TextEditingValue> {
  void jumpToTheNextLine() {
    final rawText = value.text;
    var cursorIndex = value.selection.baseOffset;
    for (; rawText[cursorIndex] != '\n'; cursorIndex++) {}
    value = TextEditingValue(
      text: "${rawText.substring(0, cursorIndex)}"
          "${rawText.substring(cursorIndex)}",
      selection: TextSelection(
        baseOffset: cursorIndex,
        extentOffset: cursorIndex,
      ),
    );
  }
}
