import 'package:dart_repl/code_editor/code_history.dart';
import 'package:flutter/cupertino.dart';

mixin CodeHistoryManager on ValueNotifier<TextEditingValue> {
  final _codeHistory = CodeHistory();

  /// Set previous state of text
  void undo() {
    final previous = _codeHistory.previous();
    if (previous != null) {
      value = TextEditingValue(
        text: previous.text,
        selection: previous.selection,
      );
    }
  }

  void addHistory(CodeHistoryNode node) {
    _codeHistory.add(node);
  }
}
