import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class CodeHistory {
  CodeHistory([this.capacity = 100]);

  final _historyNodes = <CodeHistoryNode>[];
  final int capacity;
  var _currentNodeIndex = -1;

  void add(CodeHistoryNode node) {
    // If the last node is the same as new node
    if (_currentNodeIndex != -1 &&
        (_historyNodes[_currentNodeIndex] == node ||
            _historyNodes.last == node)) {
      return;
    }

    if (_currentNodeIndex + 1 != _historyNodes.length) {
      _historyNodes.removeRange(_currentNodeIndex + 1, _historyNodes.length);
    }

    if (_historyNodes.length - 1 == capacity) {
      _currentNodeIndex--;
      _historyNodes.removeAt(0);
    }

    _currentNodeIndex++;
    _historyNodes.add(node);
  }

  CodeHistoryNode previous() {
    if (_currentNodeIndex == -1) {
      return null;
    }

    return _historyNodes[_currentNodeIndex--];
  }
}

@immutable
class CodeHistoryNode {
  const CodeHistoryNode(this.text, this.selection);

  final String text;
  final TextSelection selection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeHistoryNode &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          selection == other.selection;

  @override
  int get hashCode => text.hashCode ^ selection.hashCode;
}
