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
    this.keyboardType,
    this.obscureText = false,
    this.showShadow = false,
    this.onChanged,
    this.onSaved,
    this.onSubmit,
    this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.width = double.infinity,
    this.height = 60,
  });
  final String? id;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? initialValue;
  final Widget? prefix;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool showShadow;
  final double width;
  final double? height;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onSubmit;
  final void Function()? onClear;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;

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
    return Container(
      decoration: BoxDecoration(
        boxShadow: widget.showShadow
            ? const [
                BoxShadow(
                  offset: Offset(0, 5),
                  blurRadius: 10,
                  color: Color.fromRGBO(209, 209, 209, 1),
                ),
              ]
            : null,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextFormField(
          focusNode: widget.focusNode,
          // expands: false,
          readOnly: widget.readOnly,
          initialValue: widget.initialValue,
          decoration: InputDecoration(
            prefix: widget.prefix,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            labelText: widget.labelText,
            suffixIcon: widget.controller != null ? inputSufixIcon : null,
          ),
          controller: widget.controller,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmit,
          keyboardType: widget.keyboardType,
          obscureText: showPassword,
          maxLines: null,
          minLines: null,
          expands: true,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
        ),
      ),
    );
  }
}
