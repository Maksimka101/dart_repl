import 'package:flutter/cupertino.dart';

mixin CodeCompletionManager on ValueNotifier<TextEditingValue> {
  static const _brackets = {'(': ')', '[': ']', '{': '}', '<': '>'};

  void initializeCodeCompletion() {
    addListener(_onValueChanged);
  }

  void _onValueChanged() {
    // todo: придумать как закрывать скобки. Возможно придется использовать историю
    return;

    final rawText = value.text;
    final cursorIndex = _cursorIndex;
    final newText = rawText[cursorIndex - 1];

    // Add close bracket
    if (_isOpenBracket(newText)) {
      if (cursorIndex != rawText.length &&
          rawText[cursorIndex] != _closeBracketOf(newText)) {
        value = value.copyWith(
          text: "${rawText.substring(0, cursorIndex)}"
              "${_closeBracketOf(newText)}"
              "${rawText.substring(cursorIndex)}",
          selection: TextSelection(
            baseOffset: cursorIndex,
            extentOffset: cursorIndex,
          ),
        );
      }
    }
  }

  int get _cursorIndex =>
      value.selection.baseOffset < 0 ? 0 : value.selection.baseOffset;

  bool _isOpenBracket(String bracket) {
    return _brackets.keys.contains(bracket);
  }

  String _closeBracketOf(String bracket) {
    return _brackets[bracket];
  }

  /// Add tab (two space) before cursor
  void addTab() {
    final rawText = value.text;
    final cursorIndex = value.selection.baseOffset;
    value = TextEditingValue(
      text: "${rawText.substring(0, cursorIndex)}  "
          "${rawText.substring(cursorIndex)}",
      selection: TextSelection(
        baseOffset: cursorIndex + 2,
        extentOffset: cursorIndex + 2,
      ),
    );
  }

  @override
  void dispose() {
    removeListener(_onValueChanged);
    super.dispose();
  }
}
