import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/token.dart';

abstract class SyntaxHighlighter {
  /// Generates syntax highglighted text as list of `TextSpan` object.
  List<TextSpan> parseText(TextEditingValue tev);

  /// Insert text programatically/remotely. Method should return new TextEditingValue with inserted text.
  TextEditingValue addTextRemotely(TextEditingValue oldValue, String newText) =>
      oldValue;

  /// Handler to support enter press event.
  /// Can be used to add extra tab indents on enter press.
  TextEditingValue onEnterPress(TextEditingValue oldValue) => oldValue;

  /// Handler to support backspace press event.
  /// Can be used to remove extra tab indents on backspace press.
  TextEditingValue onBackSpacePress(
          TextEditingValue oldValue, TextSpan currentSpan) =>
      oldValue;
}

class DartSyntaxHighLighter extends SyntaxHighlighter {
  @override
  List<TextSpan> parseText(TextEditingValue tev) {
    var sourceCode = tev.text;
    final spans = <TextSpan>[];
    final parseStringResult = parseString(
      content: tev.text,
      throwIfDiagnostics: false,
    );
    var token = parseStringResult.unit.root.beginToken;
    while (!token.isEof) {
      if (token.isSynthetic) {
        token = token.next;
        continue;
      }

      final tokenVal = token.stringValue ?? token.lexeme;
      var indexOfToken = sourceCode.indexOf(tokenVal);

      if (indexOfToken > 0) {
        final commentToken = token.precedingComments;
        if (commentToken != null) {
          final indexOfComment = sourceCode.indexOf(commentToken.lexeme);
          spans.add(TextSpan(text: sourceCode.substring(0, indexOfComment)));

          sourceCode = sourceCode.substring(indexOfComment);
          spans.add(TextSpan(
            text: sourceCode.substring(0, commentToken.charCount),
            style: TextStyle(color: Color(0xFF008000)),
          ));
          sourceCode = sourceCode.substring(commentToken.charCount);

          final commentToTokenSpace = sourceCode.indexOf(tokenVal);
          spans.add(TextSpan(
            text: sourceCode.substring(0, commentToTokenSpace),
          ));
          sourceCode = sourceCode.substring(commentToTokenSpace);
        } else {
          // Code contains white spaces which is not a tokens but they must be present
          spans.add(TextSpan(text: sourceCode.substring(0, indexOfToken)));
          sourceCode = sourceCode.substring(indexOfToken);
        }
      }

      // Remove current token from source code
      sourceCode = sourceCode.substring(token.length);

      if (token.isKeyword) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFFCC7832)),
        ));
      } else if (token.isModifier) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFFCC7832)),
        ));
      } else if (token.isOperator) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFF9876AA)),
        ));
      } else if (token.type == TokenType.STRING) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFF6A8759)),
        ));
      } else if (token.type == TokenType.SEMICOLON) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFFCC7832)),
        ));
      } else if (token.type == TokenType.IDENTIFIER) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFFFFC66D)),
        ));
      } else if (token.type == TokenType.DOUBLE ||
          token.type == TokenType.INT) {
        spans.add(TextSpan(
          text: tokenVal,
          style: TextStyle(color: Color(0xFF6897BB)),
        ));
      } else {
        spans.add(TextSpan(
          text: tokenVal,
        ));
      }
      token = token.next;
    }
    if (sourceCode.isNotEmpty) {
      spans.add(TextSpan(text: sourceCode));
    }

    return spans;
  }
}
