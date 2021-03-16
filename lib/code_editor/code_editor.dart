import 'dart:async';

import 'package:dart_repl/code_editor/code_field.dart';
import 'package:dart_repl/code_editor/code_controller/code_field_controller.dart';
import 'package:dart_repl/code_editor/keyboard_listener.dart';
import 'package:dart_repl/shortcuts.dart';
import 'package:dart_repl/code_editor/syntax_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _initialCode = r"""
import 'dart:io';

void main() {
  final name = stdin.readLineSync();
  printHello(name);
}

void printHello(String name) {
  print("Hello, ${name.isEmpty ? "world" : name}");
}
""";

class CodeEditor extends StatefulWidget {
  const CodeEditor({
    @required this.editorFocusNode,
    @required this.onRun,
    @required this.onReformat,
    this.codeController,
  });

  final FocusNode editorFocusNode;
  final CodeEditingController codeController;
  final void Function() onRun;
  final void Function() onReformat;

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeEditingController _codeController;
  FocusNode _editorFocusNode;
  final _shortcutsPredictor = ShortcutPredictor();
  StreamSubscription<RawKeyEvent> _keyEventSubscription;

  @override
  void initState() {
    _codeController = widget.codeController ??
        CodeEditingController(
          syntaxHighlighter: DartSyntaxHighLighter(),
          keyboardListener: KeyboardListener.instance,
        );
    _editorFocusNode = widget.editorFocusNode ?? FocusNode();

    _codeController.text = _initialCode;

    _keyEventSubscription =
        KeyboardListener.instance.keyEvents.listen(_onKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_editorFocusNode);
    });
    super.initState();
  }

  void _onKeyEvent(RawKeyEvent keyEvent) {
    switch (_shortcutsPredictor.match(keyEvent)) {
      case ShortcutType.undo:
        _codeController.undo();
        break;
      case ShortcutType.copy:
        _codeController.copyText();
        break;
      case ShortcutType.run:
        widget.onRun();
        break;
      case ShortcutType.cut:
        _codeController.cutText();
        break;
      case ShortcutType.jumpToNextLine:
        _codeController.jumpToTheNextLine();
        break;
      case ShortcutType.tab:
        _codeController.addTab();
        break;
      case ShortcutType.none:
        break;
      case ShortcutType.restore:
        break;
      case ShortcutType.reformatCode:
        widget.onReformat();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CodeField(
      controller: widget.codeController,
      focusNode: _editorFocusNode,
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
    );
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _keyEventSubscription.cancel();
    super.dispose();
  }
}
