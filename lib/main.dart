import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dart_repl/code_editor/code_editor.dart';
import 'package:dart_repl/code_editor/code_controller/code_field_controller.dart';
import 'package:dart_repl/code_editor/keyboard_listener.dart';
import 'package:dart_repl/std_history.dart';
import 'package:dart_repl/code_editor/syntax_highlighter.dart';
import 'package:dart_repl/utils/run_mode.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DesktopWindow.setWindowSize(const Size(510, 620));
  DesktopWindow.setMinWindowSize(const Size(300, 300));
  runApp(const EditorApp());
}

class EditorApp extends StatelessWidget {
  const EditorApp();

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'JetBrainsMono'),
        child: MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              subtitle1: TextStyle(fontFamily: 'JetBrainsMono'),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
            ),
            brightness: Brightness.dark,
          ),
          home: const EditorScreen(),
        ),
      ),
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
  final _runMode = RunMode();
  CodeEditingController _codeController;
  final _stdInController = TextEditingController();
  Process _replProcess;
  final _stdInFocus = FocusNode();
  final _editorFocus = FocusNode();

  @override
  void initState() {
    _codeController = CodeEditingController(
      syntaxHighlighter: DartSyntaxHighLighter(),
      keyboardListener: KeyboardListener.instance,
    );
    super.initState();
  }

  void _onAddToStd() {
    _replProcess.stdin.add("${_stdInController.text}\n".codeUnits);
    _runHistory.add(StdInHistory(_stdInController.text));
    _stdInController.text = "";
    setState(() {});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_stdInFocus);
    });
  }

  void _onRunTapped() {
    if (_replProcess == null) {
      _onRun();
    } else {
      _replProcess.kill();
      _replProcess = null;
      setState(() {});
    }
  }

  File _replFile(String directory) => File("$directory/main.dart");

  Future<void> _onRun() async {
    final directory = await getApplicationDocumentsDirectory();
    final templatesDirectory = Directory('${directory.path}/templates');

    switch (_runMode.determineRunMode(_codeController.text)) {
      case RunModeType.dart:
        if (!Directory(
          "${templatesDirectory.path}/dart_repl_template",
        ).existsSync()) {
          final templateZip =
              await rootBundle.load('assets/templates/dart_repl_template.zip');
          final archive =
              ZipDecoder().decodeBytes(templateZip.buffer.asUint8List());
          for (final file in archive) {
            final dir = "${templatesDirectory.path}/${file.name}";
            if (file.isFile) {
              final data = file.content as List<int>;
              File(dir)
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory(dir).createSync(recursive: true);
            }
          }
        }
        final replFile =
            _replFile("${templatesDirectory.path}/dart_repl_template/src");
        await replFile.create(recursive: true);
        await replFile.writeAsString(_codeController.text);
        await Process.run(
          'pub',
          ['get'],
          workingDirectory: "${templatesDirectory.path}/dart_repl_template/",
        );
        _replProcess = await Process.start('dart', [replFile.path]);
        break;
      case RunModeType.flutter:
        if (!Directory(
          "${templatesDirectory.path}/flutter_repl_template",
        ).existsSync()) {
          final templateZip = await rootBundle
              .load('assets/templates/flutter_repl_template.zip');
          final archive =
              ZipDecoder().decodeBytes(templateZip.buffer.asUint8List());
          for (final file in archive) {
            final dir = "${templatesDirectory.path}/${file.name}";
            if (file.isFile) {
              final data = file.content as List<int>;
              File(dir)
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory(dir).createSync(recursive: true);
            }
          }
        }
        final replFile = File(
            "${templatesDirectory.path}/flutter_repl_template/lib/main.dart");
        await replFile.create(recursive: true);
        await replFile.writeAsString(_codeController.text);

        await Process.run('flutter', ['config', '--enable-windows-desktop']);
        await Process.run('flutter', ['config', '--enable-macos-desktop']);
        await Process.run('flutter', ['config', '--enable-linux-desktop']);

        _replProcess = await Process.start(
          'flutter',
          ['run'],
          workingDirectory: "${templatesDirectory.path}/flutter_repl_template",
        );
        break;
    }

    _runHistory.add(ServiceHistory("Program is started"));
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

    _replProcess.stderr
        .map((event) => String.fromCharCodes(event))
        .listen((event) {
      _runHistory.add(StdErrHistory(event));
      setState(() {});
    });

    await _replProcess.exitCode.then((value) {
      _runHistory.add(ServiceHistory("Process finished with exit code $value"));
      _replProcess = null;
      setState(() {});
    });
  }

  Future<void> _onReformat() async {
    final directory = await getApplicationDocumentsDirectory();
    final replFile = _replFile(directory.path);
    if (!directory.existsSync()) {
      await replFile.create();
    }
    await replFile.writeAsString(_codeController.text);
    await Process.run('dart', [
      'format',
      replFile.path,
    ]);
    return _codeController.value = TextEditingValue(
      selection: _codeController.selection,
      text: await replFile.readAsString(),
    );
  }

  Widget _buildUserInput() {
    return TextField(
      key: const Key("std in input"),
      controller: _stdInController,
      onEditingComplete: _onAddToStd,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      autofocus: true,
      focusNode: _stdInFocus,
    );
  }

  Widget _buildUserInputPrefix() {
    return const Text(
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
          } else if (e is StdErrHistory) {
            return Text(e.text, style: const TextStyle(color: Colors.red));
          } else {
            return Text(
              e.text,
              style: const TextStyle(color: Colors.lightGreenAccent),
            );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dart R.E.P.L."),
        toolbarHeight: 45,
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            CodeEditor(
              onReformat: _onReformat,
              onRun: _onRunTapped,
              editorFocusNode: _editorFocus,
              codeController: _codeController,
            ),
            _buildStdHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onRunTapped,
        child: Icon(_replProcess == null ? Icons.play_arrow : Icons.pause),
      ),
    );
  }
}
