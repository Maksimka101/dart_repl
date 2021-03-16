import 'dart:async';

import 'package:flutter/widgets.dart';

/// This widget helps receive keyboard event
class KeyboardListener extends StatefulWidget {
  const KeyboardListener({@required this.child});

  static KeyboardListenerState instance;

  final Widget child;

  @override
  // ignore: no_logic_in_create_state
  KeyboardListenerState createState() => instance = KeyboardListenerState();
}

class KeyboardListenerState extends State<KeyboardListener> {
  final _keyEventsController = StreamController<RawKeyEvent>.broadcast();
  RawKeyEvent _lastKeyEvent;

  Stream<RawKeyEvent> get keyEvents => _keyEventsController.stream;

  RawKeyEvent get keyEvent => _lastKeyEvent;

  void _onKey(RawKeyEvent keyEvent) {
    _lastKeyEvent = keyEvent;
    _keyEventsController.add(keyEvent);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _onKey,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _keyEventsController.close();
    super.dispose();
  }
}
