import 'dart:io';

import 'package:dart_repl/code_field.dart';
import 'package:dart_repl/code_field_controller.dart';
import 'package:dart_repl/std_history.dart';
import 'package:dart_repl/syntax_highlighter.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DesktopWindow.setWindowSize(Size(400, 600));
  DesktopWindow.setMinWindowSize(Size(300, 300));
  runApp(EditorApp());
}

class EditorApp extends StatelessWidget {
  const EditorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.white),
        brightness: Brightness.dark,
      ),
      home: EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen();

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _runHistory = <RunHistory>[];
  CodeEditingController _codeController;
  final _stdInController = TextEditingController();
  Process _replProcess;
  final _stdInFocus = FocusNode();
  final _editorFocus = FocusNode();
  final _keyboardEventsFocus =FocusNode();

  @override
  void initState() {
    _codeController = CodeEditingController(DartSyntaxHighLighter());
    _codeController.text = r"""
import 'dart:io';

void main() {
  final name = stdin.readLineSync();
  print("Hello, ${name ?? "world"}");
}
""";
    super.initState();
  }

  void _onAddToStd() {
    _replProcess.stdin.add("${_stdInController.text}\n".codeUnits);
    _runHistory.add(StdInHistory(_stdInController.text));
    _stdInController.text = "";
    setState(() {});
  }

  void _onRunTapped() {
    if (_replProcess == null) {
      _onRun();
    } else {
      _replProcess.kill();
    }
  }

  Future<void> _onRun() async {
    final directory = await getApplicationDocumentsDirectory();
    final replFile = File("${directory.path}/dart_repl.dart");
    await replFile.writeAsString(_codeController.text);
    _replProcess = await Process.start('dart', [replFile.path]);
    setState(() {});

    _replProcess.stdout
        .map((event) => String.fromCharCodes(event))
        .listen((event) {
      _runHistory.add(StdOutHistory(event));
      setState(() {});
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_stdInFocus);
    });

    _replProcess.exitCode.then((value) {
      _runHistory.add(ServiceHistory("Process finished with exit code $value"));
      _replProcess = null;
      setState(() {});
    });
  }

  void _onRawKeyboardEvent(RawKeyEvent keyEvent) {
    if (keyEvent.data.isControlPressed) {
      print("CONTROL");
    }
  }

  Widget _buildUserInput() {
    return TextField(
      controller: _stdInController,
      onEditingComplete: _onAddToStd,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      focusNode: _stdInFocus,
    );
  }

  Widget _buildUserInputPrefix() {
    return Text(
      ">>> ",
      style: TextStyle(color: Colors.purple),
    );
  }

  Widget _buildStdHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._runHistory.map((e) {
          if (e is StdInHistory) {
            return Row(
              children: [
                _buildUserInputPrefix(),
                Flexible(child: Text(e.text)),
              ],
            );
          } else if (e is StdOutHistory) {
            return Text(e.text);
          } else {
            return Text(e.text,
                style: TextStyle(color: Colors.lightGreenAccent));
          }
        }),
        if (_replProcess != null)
          Row(
            children: [
              _buildUserInputPrefix(),
              Flexible(child: _buildUserInput()),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardEventsFocus,
      autofocus: true,
      onKey: _onRawKeyboardEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dart R.E.P.L."),
          toolbarHeight: 45,
        ),
        body: ListView(
          padding: EdgeInsets.all(8),
          children: [
            CodeField(
              focusNode: _editorFocus,
              controller: _codeController,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
            _buildStdHistory(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(_replProcess == null ? Icons.play_arrow : Icons.pause),
          onPressed: _onRunTapped,
        ),
      ),
    );
  }
}
