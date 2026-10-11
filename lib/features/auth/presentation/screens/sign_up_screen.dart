import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_fields.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_scaffold.dart';

/// The values entered on the sign-up form. Names and emails are trimmed;
/// passwords are passed exactly as typed.
typedef SignUpDetails = ({
  String fullName,
  String email,
  String password,
  String confirmPassword,
});

/// The account-creation screen, with Google as an alternative and a link back
/// to sign in. Visually consistent with the Login screen (same
/// [AuthScaffold]).
///
/// Presentation only: the fields are checked against the domain validation
/// rules, then every action is reported through a callback and the caller
/// decides what happens. The caller reports progress and failures back
/// through [isSubmitting], [isGoogleSubmitting] and [errorMessage].
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.onBack,
    required this.onCreateAccount,
    required this.onContinueWithGoogle,
    required this.onSignIn,
    this.isSubmitting = false,
    this.isGoogleSubmitting = false,
    this.errorMessage,
  });

  /// Total length of the staggered entrance animation.
  static const Duration entranceDuration = AuthScaffold.entranceDuration;

  /// The longer form leaves less room for the illustration than on Login.
  static const double _illustrationScale = 0.7;

  final VoidCallback onBack;

  /// Called once every field passes validation.
  final ValueChanged<SignUpDetails> onCreateAccount;
  final VoidCallback onContinueWithGoogle;
  final VoidCallback onSignIn;

  /// Shows the Create Account button's loading state and ignores further
  /// submits.
  final bool isSubmitting;

  /// Shows the Google button's loading state and ignores further submits.
  final bool isGoogleSubmitting;

  /// A failed registration or Google sign-in attempt, shown above the Create
  /// Account button.
  final String? errorMessage;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  /// Fields re-check as the user types only after a submit was rejected.
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// Only one attempt (registration or Google) runs at a time.
  bool get _busy => widget.isSubmitting || widget.isGoogleSubmitting;

  void _submit() {
    if (_busy) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }
    widget.onCreateAccount((
      fullName: _fullName.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      confirmPassword: _confirmPassword.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = widget.errorMessage;

    return AuthScaffold(
      onBack: widget.onBack,
      title: 'Create Your Account',
      subtitle: 'Sign up to start using Splitzy',
      illustrationScale: SignUpScreen._illustrationScale,
      onContinueWithGoogle: _busy ? null : widget.onContinueWithGoogle,
      isGoogleLoading: widget.isGoogleSubmitting,
      switchPrompt: 'Already have an account?',
      switchActionLabel: 'Sign In',
      onSwitch: widget.onSignIn,
      form: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullName,
                validator: (value) =>
                    AuthValidation.fullName(value ?? '')?.message,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              EmailField(
                controller: _email,
                validator: (value) =>
                    AuthValidation.email(value ?? '')?.message,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                validator: (value) =>
                    AuthValidation.newPassword(value ?? '')?.message,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirmPassword,
                validator: (value) => AuthValidation.passwordConfirmation(
                  _password.text,
                  value ?? '',
                )?.message,
                hintText: 'Confirm password',
                visibilityLabel: 'confirm password',
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (errorMessage != null) ...[
                AuthErrorText(errorMessage),
                const SizedBox(height: AppSpacing.sm),
              ],
              PrimaryArrowButton(
                label: 'Create Account',
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
