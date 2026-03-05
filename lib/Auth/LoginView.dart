import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskhub/Auth/SignupView.dart';
import 'AuthService.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSendingReset = false;

  late final AnimationController _masterController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _headingFade;
  late final Animation<Offset> _headingSlide;
  late final Animation<double> _emailFade;
  late final Animation<Offset> _emailSlide;
  late final Animation<double> _passwordFade;
  late final Animation<Offset> _passwordSlide;
  late final Animation<double> _bottomFade;
  late final Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
          ),
        );

    _headingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.14, 0.36, curve: Curves.easeOut),
      ),
    );
    _headingSlide =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.14, 0.36, curve: Curves.easeOut),
          ),
        );

    _emailFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.25, 0.46, curve: Curves.easeOut),
      ),
    );
    _emailSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.25, 0.46, curve: Curves.easeOut),
          ),
        );

    _passwordFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.36, 0.57, curve: Curves.easeOut),
      ),
    );
    _passwordSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.36, 0.57, curve: Curves.easeOut),
          ),
        );

    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _masterController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) _showSnack('Login failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Enter your email address above first.', isError: true);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnack('Enter a valid email address.', isError: true);
      return;
    }

    setState(() => _isSendingReset = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) _showSnack('Password reset email sent to $email.');
    } catch (e) {
      if (mounted) {
        _showSnack(
          'Could not send reset email: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  void _goToSignUp() => Navigator.push(context, _fadeRoute(const SignUpPage()));

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? Colors.white
                    : isDark
                    ? const Color(0xFFF5C842)
                    : cs.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: isError ? Colors.white : cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? const Color(0xFFCF4444)
              : isDark
              ? const Color(0xFF2A3447)
              : Colors.white,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _AnimatedItem(
                  fade: _logoFade,
                  slide: _logoSlide,
                  child: _buildLogo(),
                ),
                const SizedBox(height: 48),
                _AnimatedItem(
                  fade: _headingFade,
                  slide: _headingSlide,
                  child: _buildHeading(),
                ),
                const SizedBox(height: 32),
                _AnimatedItem(
                  fade: _emailFade,
                  slide: _emailSlide,
                  child: _buildEmailField(),
                ),
                const SizedBox(height: 20),
                _AnimatedItem(
                  fade: _passwordFade,
                  slide: _passwordSlide,
                  child: _buildPasswordField(),
                ),
                const SizedBox(height: 12),
                _AnimatedItem(
                  fade: _bottomFade,
                  slide: _bottomSlide,
                  child: Column(
                    children: [
                      _buildForgotPassword(),
                      const SizedBox(height: 32),
                      _buildLoginButton(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildSignUpRow(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(isDark ? 0.25 : 0.15),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: cs.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.task_alt_rounded, size: 38, color: cs.primary),
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Day',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Task',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue managing your day.',
          style: TextStyle(color: subColor, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _FieldWrapper(
      label: 'Email Address',
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
        ),
        decoration: _inputDecoration(
          hint: 'Email Address',
          icon: Icons.alternate_email_rounded,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Please enter your email';
          if (!v.contains('@') || !v.contains('.'))
            return 'Please enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return _FieldWrapper(
      label: 'Password',
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
        ),
        decoration:
            _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8A97B0)
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your password';
          if (v.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
    );
  }

  Widget _buildForgotPassword() {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _isSendingReset ? null : _forgotPassword,
        child: _isSendingReset
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : Text(
                'Forgot Password?',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: cs.onPrimary,
                ),
              )
            : const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divColor = isDark ? const Color(0xFF2A3447) : Colors.grey.shade300;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Row(
      children: [
        Expanded(child: Divider(color: divColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or', style: TextStyle(color: subColor, fontSize: 13)),
        ),
        Expanded(child: Divider(color: divColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSignUpRow() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: subColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: _goToSignUp,
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: cs.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2A3447) : Colors.grey.shade300;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subColor.withOpacity(0.7), fontSize: 15),
      prefixIcon: Icon(icon, color: subColor, size: 20),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFE05252)),
    );
  }
}

class _FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  const _AnimatedItem({
    required this.fade,
    required this.slide,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
