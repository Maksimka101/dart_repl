import 'dart:ui';

import 'package:dart_repl/code_field_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeField extends TextField {
  const CodeField({
    Key key,
    CodeEditingController controller,
    FocusNode focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextInputType keyboardType,
    TextInputAction textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle style,
    StrutStyle strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical,
    TextDirection textDirection,
    bool readOnly = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    void Function(String) onChanged,
    void Function() onEditingComplete,
    void Function(String) onSubmitted,
    List<TextInputFormatter> inputFormatters,
    bool enabled,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Iterable<String> autofillHints,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool enableInteractiveSelection = true,
    void Function() onTap,
    Widget Function(BuildContext,
            {int currentLength, bool isFocused, int maxLength})
        buildCounter,
    ScrollController scrollController,
    ScrollPhysics scrollPhysics,
  }) : super(
          controller: controller,
          key: key,
          focusNode: focusNode,
          decoration: decoration,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          textDirection: textDirection,
          readOnly: readOnly,
          toolbarOptions: toolbarOptions,
          showCursor: showCursor,
          autofocus: autofocus,
          obscureText: obscureText,
          autocorrect: autocorrect,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          enableSuggestions: enableSuggestions,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorColor: cursorColor,
          selectionHeightStyle: selectionHeightStyle,
          selectionWidthStyle: selectionWidthStyle,
          keyboardAppearance: keyboardAppearance,
          scrollPadding: scrollPadding,
          dragStartBehavior: dragStartBehavior,
          enableInteractiveSelection: enableInteractiveSelection,
          onTap: onTap,
          buildCounter: buildCounter,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
          autofillHints: autofillHints,
        );
}
