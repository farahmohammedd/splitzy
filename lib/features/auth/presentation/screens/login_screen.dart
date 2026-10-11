import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_fields.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_scaffold.dart';

/// The email/password login screen, with Google as an alternative and a link
/// to sign up.
///
/// Presentation only: the fields are checked against the domain validation
/// rules, then every action is reported through a callback and the caller
/// decides what happens. The caller reports progress and failures back
/// through [isSubmitting], [isGoogleSubmitting] and [errorMessage].
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onBack,
    required this.onLogIn,
    required this.onForgotPassword,
    required this.onContinueWithGoogle,
    required this.onSignUp,
    this.isSubmitting = false,
    this.isGoogleSubmitting = false,
    this.errorMessage,
  });

  /// Total length of the staggered entrance animation.
  static const Duration entranceDuration = AuthScaffold.entranceDuration;

  final VoidCallback onBack;

  /// Called with the entered email (trimmed) and password once both fields
  /// pass validation.
  final void Function(String email, String password) onLogIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onContinueWithGoogle;
  final VoidCallback onSignUp;

  /// Shows the Log In button's loading state and ignores further submits.
  final bool isSubmitting;

  /// Shows the Google button's loading state and ignores further submits.
  final bool isGoogleSubmitting;

  /// A failed log-in attempt (email or Google), shown above the Log In
  /// button.
  final String? errorMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Fields re-check as the user types only after a submit was rejected.
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Only one sign-in attempt (email or Google) runs at a time.
  bool get _busy => widget.isSubmitting || widget.isGoogleSubmitting;

  void _submit() {
    if (_busy) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }
    widget.onLogIn(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = widget.errorMessage;

    return AuthScaffold(
      onBack: widget.onBack,
      title: 'Welcome Back',
      subtitle: 'Log in to continue to Splitzy',
      onContinueWithGoogle: _busy ? null : widget.onContinueWithGoogle,
      isGoogleLoading: widget.isGoogleSubmitting,
      switchPrompt: 'Don’t have an account?',
      switchActionLabel: 'Sign Up',
      onSwitch: widget.onSignUp,
      form: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EmailField(
                controller: _email,
                validator: (value) =>
                    AuthValidation.email(value ?? '')?.message,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                validator: (value) =>
                    AuthValidation.signInPassword(value ?? '')?.message,
                onSubmitted: _submit,
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),
              if (errorMessage != null) ...[
                AuthErrorText(errorMessage),
                const SizedBox(height: AppSpacing.sm),
              ] else
                const SizedBox(height: AppSpacing.xs),
              PrimaryArrowButton(
                label: 'Log In',
                onPressed: _submit,
                isLoading: widget.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
