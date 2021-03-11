abstract class RunHistory {
  RunHistory(this.text);

  final String text;
}

class StdInHistory extends RunHistory {
  StdInHistory(String text) : super(text);
}

class StdOutHistory extends RunHistory {
  StdOutHistory(String text) : super(text);
}

class ServiceHistory extends RunHistory {
  ServiceHistory(String text) : super(text);
}

class StdErrHistory extends RunHistory {
  StdErrHistory(String text) : super(text);
}
