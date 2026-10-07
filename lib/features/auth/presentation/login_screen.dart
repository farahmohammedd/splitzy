import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/fade_slide_in.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';
import 'package:splitzy/features/auth/presentation/widgets/google_mark.dart';
import 'package:splitzy/features/auth/presentation/widgets/login_background.dart';

/// The email/password login screen, with Google as an alternative and a link
/// to sign up.
///
/// Presentation only: every action is reported through a callback and the
/// caller decides what happens. No validation or authentication happens here.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onBack,
    required this.onLogIn,
    required this.onForgotPassword,
    required this.onContinueWithGoogle,
    required this.onSignUp,
  });

  /// Total length of the staggered entrance animation.
  static const Duration entranceDuration = Duration(milliseconds: 900);

  final VoidCallback onBack;

  /// Called with the entered email (trimmed) and password.
  final void Function(String email, String password) onLogIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onContinueWithGoogle;
  final VoidCallback onSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LoginScreen.entranceDuration,
  );

  // Subtle staggered entrance: illustration, heading, form, then the rest.
  late final Animation<double> _illustration = _interval(0, 0.5);
  late final Animation<double> _heading = _interval(0.2, 0.65);
  late final Animation<double> _form = _interval(0.35, 0.85);
  late final Animation<double> _footer = _interval(0.5, 1);

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => widget.onLogIn(_email.text.trim(), _password.text);

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    // With reduced motion, everything is shown in its final state at once.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const shown = AlwaysStoppedAnimation<double>(1);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LoginBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              final gap = compact ? AppSpacing.sm : AppSpacing.lg;
              final contentWidth =
                  math.min(constraints.maxWidth, AppSizes.maxContentWidth) -
                  AppSpacing.xl * 2;
              final illustrationHeight = math.min(
                contentWidth / _illustrationAspectRatio,
                constraints.maxHeight * (compact ? 0.16 : 0.27),
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            _IllustrationHeader(
                              animation: reduceMotion ? shown : _illustration,
                              height: illustrationHeight,
                              onBack: widget.onBack,
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _heading,
                              offsetY: 0.2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Log in to continue to Splitzy',
                                    style: textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _form,
                              offsetY: 0.05,
                              child: _CredentialsForm(
                                email: _email,
                                password: _password,
                                obscurePassword: _obscurePassword,
                                onTogglePasswordVisibility:
                                    _togglePasswordVisibility,
                                onForgotPassword: widget.onForgotPassword,
                                onSubmit: _submit,
                              ),
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _footer,
                              offsetY: 0.1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _OrDivider(),
                                  SizedBox(height: gap),
                                  _GoogleButton(
                                    onPressed: widget.onContinueWithGoogle,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: AppSpacing.md),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _footer,
                              offsetY: 0.2,
                              child: _SignUpPrompt(onSignUp: widget.onSignUp),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Width / height of `login_friends.png`.
  static const double _illustrationAspectRatio = 1.5;
}

/// The friends illustration with the back button over its top-left corner.
class _IllustrationHeader extends StatelessWidget {
  const _IllustrationHeader({
    required this.animation,
    required this.height,
    required this.onBack,
  });

  static const double _sageDotRadius = 40;

  final Animation<double> animation;
  final double height;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final width = height * _LoginScreenState._illustrationAspectRatio;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circle peeking in from the screen edge, just below the
          // illustration (anchored here so it never sits behind the title).
          Positioned(
            left: -AppSpacing.xl - _sageDotRadius,
            bottom: -_sageDotRadius * 0.6,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Container(
                  width: _sageDotRadius * 2,
                  height: _sageDotRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: FadeSlideIn(
              animation: animation,
              offsetY: 0.06,
              child: Image.asset(
                AppImages.loginFriends,
                width: width,
                height: height,
                cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                semanticLabel: 'Three friends splitting a bill',
              ),
            ),
          ),
          Positioned(
            // Align the icon (not its tap target) with the content edge.
            left: -AppSpacing.md,
            top: 0,
            child: IconButton(
              onPressed: onBack,
              color: scheme.onSurface,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialsForm extends StatelessWidget {
  const _CredentialsForm({
    required this.email,
    required this.password,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: password,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          PrimaryArrowButton(label: 'Log In', onPressed: onSubmit),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // One full-width line with the label on a background-colored patch, so
    // the label can wrap at large text sizes instead of overflowing a Row.
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(),
        ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'or continue with',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GoogleMark(size: 22),
          SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text('Continue with Google', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onSignUp});

  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Don’t have an account?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(onPressed: onSignUp, child: const Text('Sign Up')),
      ],
    );
  }
}
