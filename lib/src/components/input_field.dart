import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.id,
    this.labelText,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.prefix,
    this.prefixIcon,
    this.validator,
    this.onEditingComplete,
    this.obscureText = false,
    this.showShadow = false,
    this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.width = double.infinity,
    this.height = 60,
    this.multiline = false,
  });
  final String? id;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? initialValue;
  final Widget? prefix;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final bool showShadow;
  final double width;
  final double? height;
  final void Function()? onClear;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final bool multiline;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool showPassword;
  late IconButton? inputSufixIcon;

  @override
  void initState() {
    super.initState();
    showPassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    inputSufixIcon = widget.obscureText
        ? IconButton(
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 24),
            padding: const EdgeInsets.only(top: 2),
            onPressed: () {
              setState(() {
                if (showPassword) {
                  showPassword = false;
                } else {
                  showPassword = true;
                }
              });
            },
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              size: 18,
            ),
          )
        : widget.controller != null && !widget.readOnly
            ? IconButton(
                iconSize: 18,
                constraints: const BoxConstraints(minWidth: 24),
                padding: const EdgeInsets.only(top: 2),
                onPressed: () {
                  widget.controller!.clear();
                  if (widget.onClear != null) widget.onClear!();
                },
                icon: const Icon(
                  Icons.clear,
                  size: 18,
                ),
              )
            : null;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        initialValue: widget.initialValue,
        decoration: InputDecoration(
          prefix: widget.prefix,
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Icon(widget.prefixIcon),
                )
              : null,
          labelText: widget.labelText,
          suffixIcon: widget.controller != null ? inputSufixIcon : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
        controller: widget.controller,
        obscureText: showPassword,
        maxLines: widget.multiline ? null : 1,
        minLines: widget.multiline ? null : 1,
        expands: widget.multiline ? true : false,
        validator: widget.validator,
        onEditingComplete: widget.onEditingComplete,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
      ),
    );
  }
}
