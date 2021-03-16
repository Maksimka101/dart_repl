import 'package:dart_repl/code_editor/keyboard_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

mixin CodeCompletionManager on ValueNotifier<TextEditingValue> {
  static const _brackets = {
    '(': ')',
    '[': ']',
    '{': '}',
    '<': '>',
    '"': '"',
    "'": "'",
  };
  var _lastValue = '';

  KeyboardListenerState _keyboardListener;

  void initializeCodeCompletion(KeyboardListenerState keyboardListener) {
    _keyboardListener = keyboardListener;
    addListener(_onValueChanged);
  }

  void _onValueChanged() {
    final rawText = value.text;
    final cursorIndex = _cursorIndex;

    if (cursorIndex == 0 || _lastValue == rawText) {
      return;
    }

    final newText = rawText[cursorIndex - 1];

    // If there was not taps
    if (_keyboardListener.keyEvent == null) {
      _lastValue = rawText;
      return;
    }

    // Add close bracket
    if (_isOpenBracket(newText) &&
        _isOpenBracketKey(_keyboardListener.keyEvent)) {
      _lastValue = "${rawText.substring(0, cursorIndex)}"
          "${_closeBracketOf(newText)}"
          "${rawText.substring(cursorIndex)}";
      value = value.copyWith(
        text: _lastValue,
        selection: TextSelection(
          baseOffset: cursorIndex,
          extentOffset: cursorIndex,
        ),
      );
    }

    if (_keyboardListener.keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
      // {|}
      // | - cursor
      // Press enter to open brackets like below
      // {
      //   |
      // }
      if (cursorIndex > 1 && _isOpenBracket(rawText[cursorIndex - 2])) {
        final containsCloseBracket = cursorIndex < rawText.length &&
            _isCloseBracket(rawText[cursorIndex]);

        final previousLinePadding = _getPreviousLinePadding();
        _lastValue = "${rawText.substring(0, cursorIndex)}"
            "${' ' * previousLinePadding}  "
            "${containsCloseBracket ? '\n${' ' * previousLinePadding}' : ''}"
            "${rawText.substring(cursorIndex)}";
        value = value.copyWith(
          text: _lastValue,
          selection: TextSelection(
            baseOffset: cursorIndex + previousLinePadding + 2,
            extentOffset: cursorIndex + previousLinePadding + 2,
          ),
        );
      } else {
        final previousLinePadding = _getPreviousLinePadding();
        _lastValue = "${rawText.substring(0, cursorIndex)}"
            "${' ' * previousLinePadding}"
            "${rawText.substring(cursorIndex)}";
        value = value.copyWith(
          text: _lastValue,
          selection: TextSelection(
            baseOffset: cursorIndex + previousLinePadding,
            extentOffset: cursorIndex + previousLinePadding,
          ),
        );
      }
    }

    _lastValue = value.text;
  }

  /// Returns count of spaces at previous line
  /// Used to start new line with the same padding as at the previous line
  int _getPreviousLinePadding() {
    final rawText = value.text;
    var cursorIndex = _cursorIndex;

    for (var i = 0; i < 2; i++) {
      while (cursorIndex > 0 && rawText[cursorIndex - 1] != "\n") {
        cursorIndex--;
      }

      if (cursorIndex == 0) {
        return 0;
      }

      cursorIndex--;
    }
    cursorIndex++;

    var spaces = 0;
    while (rawText[cursorIndex] == ' ') {
      cursorIndex++;
      spaces++;
    }

    return spaces;
  }

  int get _cursorIndex =>
      value.selection.baseOffset < 0 ? 0 : value.selection.baseOffset;

  bool _isOpenBracket(String bracket) {
    return _brackets.keys.contains(bracket);
  }

  bool _isCloseBracket(String bracket) {
    return _brackets.values.contains(bracket);
  }

  bool _isOpenBracketKey(RawKeyEvent keyEvent) {
    return _isOpenBracket(keyEvent.character);
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
