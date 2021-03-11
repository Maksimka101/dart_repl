import 'package:dart_repl/syntax_highlighter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CodeEditingController extends ValueNotifier<TextEditingValue>
    implements TextEditingController {
  final SyntaxHighlighter syntaxHighlighter;

  /// Creates a controller for an editable text field.
  ///
  /// This constructor treats a null [text] argument as if it were the empty
  /// string.
  CodeEditingController(this.syntaxHighlighter, {String text})
      : super(text == null
            ? TextEditingValue.empty
            : TextEditingValue(text: text));

  /// Creates a controller for an editable text field from an initial [TextEditingValue].
  ///
  /// This constructor treats a null [value] argument as if it were
  /// [TextEditingValue.empty].
  CodeEditingController.fromValue(
      TextEditingValue value, this.syntaxHighlighter)
      : super(value ?? TextEditingValue.empty) {
    addListener(() {
      print("Text changed");
    });
  }

  final _codeHistory = CodeHistory();

  /// The current string the user is editing.
  String get text => value.text;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [TextEditingController]; however, one should not also set [selection]
  /// in a separate statement. To change both the [text] and the [selection]
  /// change the controller's [value].
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  /// Builds [TextSpan] from current editing value.
  ///
  /// By default makes text in composing range appear as underlined.
  /// Descendants can override this method to customize appearance of text.
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    // if (!value.composing.isValid || !withComposing) {
    //   return TextSpan(style: style, text: text);
    // }

    _codeHistory.add(CodeHistoryNode(value.text, value.selection));

    var lsSpans = syntaxHighlighter.parseText(value);

    return TextSpan(style: style, children: lsSpans);
  }

  /// The currently selected [text].
  ///
  /// If the selection is collapsed, then this property gives the offset of the
  /// cursor within the text.
  TextSelection get selection => value.selection;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [TextEditingController]; however, one should not also set [text]
  /// in a separate statement. To change both the [text] and the [selection]
  /// change the controller's [value].
  set selection(TextSelection newSelection) {
    if (!isSelectionWithinTextBounds(newSelection))
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('invalid text selection: $newSelection')
      ]);
    value = value.copyWith(selection: newSelection, composing: TextRange.empty);
  }

  /// Set the [value] to empty.
  ///
  /// After calling this function, [text] will be the empty string and the
  /// selection will be invalid.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clear() {
    value = TextEditingValue.empty;
  }

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

  /// If text selected then copy selected text [implicitly by flutter]
  /// If text is not selected copy all string
  void copyText() {
    if (selection.isCollapsed) {
      final rawText = text;
      final cursorIndex = selection.start;
      var beforeCursor = cursorIndex;
      var afterCursor = cursorIndex;
      for (;
          beforeCursor != -1 && rawText[beforeCursor] != '\n';
          beforeCursor--) {}
      for (;
          afterCursor != rawText.length && rawText[afterCursor] != '\n';
          afterCursor++) {}
      final line = "\n${rawText.substring(beforeCursor++, afterCursor)}\n";

      Clipboard.setData(ClipboardData(text: line));
      Clipboard.getData(Clipboard.kTextPlain).then((value) => print(value.text));
      selection = TextSelection(
        baseOffset: beforeCursor,
        extentOffset: afterCursor,
      );
    }
  }

  /// Set next state of text
  /// Now id doesn't work
  void restore() {
    // todo: implement restore
  }

  /// Check that the [selection] is inside of the bounds of [text].
  bool isSelectionWithinTextBounds(TextSelection selection) {
    return selection.start <= text.length && selection.end <= text.length;
  }

  /// Set the composing region to an empty range.
  ///
  /// The composing region is the range of text that is still being composed.
  /// Calling this function indicates that the user is done composing that
  /// region.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clearComposing() {
    value = value.copyWith(composing: TextRange.empty);
  }
}

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

class CodeHistoryNode {
  CodeHistoryNode(this.text, this.selection);

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
