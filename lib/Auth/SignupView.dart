import 'package:flutter/material.dart';
import 'package:taskhub/Auth/LoginView.dart';
import 'AuthService.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  late final AnimationController _masterController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _headingFade;
  late final Animation<Offset> _headingSlide;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
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
      duration: const Duration(milliseconds: 1600),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.19, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.0, 0.19, curve: Curves.easeOut),
          ),
        );

    _headingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.12, 0.28, curve: Curves.easeOut),
      ),
    );
    _headingSlide =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.12, 0.28, curve: Curves.easeOut),
          ),
        );

    _nameFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.19, 0.37, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.19, 0.37, curve: Curves.easeOut),
          ),
        );

    _emailFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.28, 0.47, curve: Curves.easeOut),
      ),
    );
    _emailSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.28, 0.47, curve: Curves.easeOut),
          ),
        );

    _passwordFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.37, 0.56, curve: Curves.easeOut),
      ),
    );
    _passwordSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.37, 0.56, curve: Curves.easeOut),
          ),
        );

    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.5, 0.69, curve: Curves.easeOut),
      ),
    );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _masterController,
            curve: const Interval(0.5, 0.69, curve: Curves.easeOut),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _masterController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showSnack(
        'Please agree to the Privacy Policy and Terms & Conditions.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, _fadeRoute(const LoginView()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please log in.'),
          backgroundColor: const Color(0xFF2A7A4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      _showSnack('Signup failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() =>
      Navigator.pushReplacement(context, _fadeRoute(const LoginView()));

  void _showSnack(String msg, {bool isError = false}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFE05252) : cs.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
                const SizedBox(height: 8),
                _AnimatedItem(
                  fade: _logoFade,
                  slide: _logoSlide,
                  child: _buildLogo(),
                ),
                const SizedBox(height: 40),
                _AnimatedItem(
                  fade: _headingFade,
                  slide: _headingSlide,
                  child: _buildHeading(),
                ),
                const SizedBox(height: 28),
                _AnimatedItem(
                  fade: _nameFade,
                  slide: _nameSlide,
                  child: _FieldWrapper(
                    label: 'Full Name',
                    child: TextFormField(
                      controller: _fullNameController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Full Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter your full name';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _AnimatedItem(
                  fade: _emailFade,
                  slide: _emailSlide,
                  child: _FieldWrapper(
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
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter your email';
                        if (!RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v))
                          return 'Please enter a valid email';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _AnimatedItem(
                  fade: _passwordFade,
                  slide: _passwordSlide,
                  child: _FieldWrapper(
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF8A97B0)
                                    : const Color(0xFF6B7280),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your password';
                        if (v.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _AnimatedItem(
                  fade: _bottomFade,
                  slide: _bottomSlide,
                  child: Column(
                    children: [
                      _buildTermsRow(),
                      const SizedBox(height: 28),
                      _buildSignUpButton(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildLoginRow(),
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
          'Create account',
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
          'Start organising your day in seconds.',
          style: TextStyle(color: subColor, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTermsRow() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF8A97B0) : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreedToTerms ? cs.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms ? cs.primary : borderColor,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? Icon(Icons.check_rounded, size: 15, color: cs.onPrimary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: subColor, fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: 'I have read & agreed to DayTask '),
                  TextSpan(
                    text: 'Privacy Policy, Terms & Conditions',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignUp,
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
                'Create Account',
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

  Widget _buildLoginRow() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: subColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: _goToLogin,
          child: Text(
            'Log In',
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
