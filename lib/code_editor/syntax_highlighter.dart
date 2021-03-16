import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/analysis/declared_variables.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/analysis/uri_converter.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/ast_factory.dart';
import 'package:analyzer/dart/ast/precedence.dart';
import 'package:analyzer/dart/ast/standard_ast_factory.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/sdk/build_sdk_summary.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/instrumentation/file_instrumentation.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';
import 'package:analyzer/instrumentation/log_adapter.dart';
import 'package:analyzer/instrumentation/logger.dart';
import 'package:analyzer/instrumentation/multicast_service.dart';
import 'package:analyzer/instrumentation/noop_service.dart';
import 'package:analyzer/instrumentation/plugin_data.dart';
import 'package:analyzer/instrumentation/service.dart';
import 'package:analyzer/source/error_processor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';

abstract class SyntaxHighlighter {
  /// Generates syntax highlighted text as list of `TextSpan` object.
  List<TextSpan> parseText(TextEditingValue tev);
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

    final errorsOffset = Map.fromEntries(parseStringResult.errors.map(
      (e) => MapEntry(e.offset, e),
    ));

    var token = parseStringResult.unit.root.beginToken;
    while (!token.isEof) {
      if (token.isSynthetic) {
        token = token.next;
        continue;
      }
      final errorToken = errorsOffset[token.offset];
      final textStyle = TextStyle(
        decoration: errorToken != null ? TextDecoration.underline : null,
        decorationColor: Colors.red,
      );

      final tokenVal = token.stringValue ?? token.lexeme;
      var indexOfToken = sourceCode.indexOf(tokenVal);

      if (indexOfToken > 0) {
        final commentToken = token.precedingComments;
        // Add colors for comment
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
          style: textStyle.copyWith(color: Color(0xFFCC7832)),
        ));
      } else if (token.isModifier) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFFCC7832)),
        ));
      } else if (token.isOperator) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFF9876AA)),
        ));
      } else if (token.type == TokenType.STRING) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFF6A8759)),
        ));
      } else if (token.type == TokenType.SEMICOLON) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFFCC7832)),
        ));
      } else if (token.type == TokenType.IDENTIFIER) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFFFFC66D)),
        ));
      } else if (token.type == TokenType.DOUBLE ||
          token.type == TokenType.INT) {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle.copyWith(color: Color(0xFF6897BB)),
        ));
      } else {
        spans.add(TextSpan(
          text: tokenVal,
          style: textStyle,
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
