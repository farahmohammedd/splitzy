import 'package:flutter/material.dart';

/// Email input shared by the authentication screens.
class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller, this.validator});

  final TextEditingController controller;

  /// Returns an error message to show under the field, or `null` if valid.
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      decoration: const InputDecoration(
        hintText: 'Email address',
        prefixIcon: Icon(Icons.mail_outline_rounded),
      ),
    );
  }
}

/// Password input with its own show/hide toggle, shared by the
/// authentication screens.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Password',
    this.visibilityLabel = 'password',
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;

  /// Returns an error message to show under the field, or `null` if valid.
  final FormFieldValidator<String>? validator;
  final String hintText;

  /// Used in the toggle's tooltip: "Show <label>" / "Hide <label>". Distinct
  /// labels keep multiple password fields distinguishable for screen readers.
  final String visibilityLabel;
  final Iterable<String> autofillHints;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final onSubmitted = widget.onSubmitted;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          tooltip: '${_obscured ? 'Show' : 'Hide'} ${widget.visibilityLabel}',
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
