import 'package:dart_repl/code_editor/code_field.dart';
import 'package:dart_repl/code_editor/code_controller/code_field_controller.dart';
import 'package:dart_repl/shortcuts.dart';
import 'package:dart_repl/code_editor/syntax_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({
    @required this.editorFocusNode,
    @required this.onRun,
    this.codeController,
  });

  final FocusNode editorFocusNode;
  final CodeEditingController codeController;
  final void Function() onRun;

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeEditingController _codeController;
  FocusNode _editorFocusNode;
  final _shortcutsPredictor = ShortcutPredictor();

  @override
  void initState() {
    _codeController = widget.codeController ??
        CodeEditingController(
          DartSyntaxHighLighter(),
        );
    _editorFocusNode = widget.editorFocusNode ?? FocusNode();
    _codeController.text = r"""
import 'dart:io';

void main() {
  final name = stdin.readLineSync();
  printHello(name);
}

void printHello(String name) {
  print("Hello, ${name.isEmpty ? "world" : name}");
}
""";
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _onKeyEvent,
      child: CodeField(
        controller: widget.codeController,
        focusNode: _editorFocusNode,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(fontFamily: 'JetBrainsMono'),
      ),
    );
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
