import 'package:dart_repl/code_editor/code_controller/clipboard_mixin.dart';
import 'package:dart_repl/code_editor/code_history.dart';
import 'package:dart_repl/code_editor/code_controller/code_completion_mixin.dart';
import 'package:dart_repl/code_editor/code_controller/code_history_mixin.dart';
import 'package:dart_repl/code_editor/code_controller/code_navigation_mixin.dart';
import 'package:dart_repl/code_editor/syntax_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CodeEditingController extends ValueNotifier<TextEditingValue>
    with
        CodeCompletionManager,
        CodeHistoryManager,
        CodeNavigationManager,
        ClipboardManager
    implements TextEditingController {
  /// Creates a controller for an editable text field.
  ///
  /// This constructor treats a null [text] argument as if it were the empty
  /// string.
  CodeEditingController(this.syntaxHighlighter, {String text})
      : super(text == null
            ? TextEditingValue.empty
            : TextEditingValue(text: text)) {
    initializeCodeCompletion();
  }

  /// Creates a controller for an editable text field from an initial [TextEditingValue].
  ///
  /// This constructor treats a null [value] argument as if it were
  /// [TextEditingValue.empty].
  CodeEditingController.fromValue(
    TextEditingValue value,
    this.syntaxHighlighter,
  ) : super(value ?? TextEditingValue.empty) {
    initializeCodeCompletion();
  }

  final SyntaxHighlighter syntaxHighlighter;

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
    addHistory(CodeHistoryNode(value.text, value.selection));

    final spans = syntaxHighlighter.parseText(value);

    return TextSpan(style: style, children: spans);
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
