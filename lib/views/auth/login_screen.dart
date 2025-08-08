
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  // Color palette consistent with SignUp
  final Color backgroundColor = const Color(0xFF19485C);
  final Color fieldColor = const Color(0xFF287191);
  final Color focusedColor = Colors.white;
  final Color buttonActiveColor = const Color.fromARGB(255, 10, 79, 102);
  final Color buttonDisabledColor = Colors.grey;
  final Color buttonBorderColor = const Color.fromARGB(202, 255, 255, 255);
  final Color errorColor = const Color.fromARGB(255, 204, 203, 203);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get isValidEmail {
    final value = _emailController.text.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value);
  }

  bool get isEmailTouched => _emailController.text.isNotEmpty;
  bool get isPasswordTouched => _passwordController.text.isNotEmpty;

  bool get isFormValid =>
      isValidEmail && _passwordController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          final bool isDisabled = authVM.isLoading || !isFormValid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hintText: 'Email',
                    icon: Icons.email,
                    hasError: isEmailTouched && !isValidEmail,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (isEmailTouched && !isValidEmail)
                  _errorText('Invalid email format'),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: _inputDecoration(
                    hintText: 'Password',
                    icon: Icons.lock,
                    hasError: isPasswordTouched &&
                        _passwordController.text.trim().isEmpty,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (isPasswordTouched &&
                    _passwordController.text.trim().isEmpty)
                  _errorText('Please enter your password'),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot'),
                    child: const Text('Forgot password?',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(height: 10),

                // Global login error
                if (authVM.loginError != null) _errorText(authVM.loginError!),
                const SizedBox(height: 10),

                // Login Button
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 45,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDisabled ? buttonDisabledColor : buttonActiveColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDisabled
                                ? const Color.fromARGB(66, 134, 133, 133)
                                : buttonBorderColor,
                            width: 1.8,
                          ),
                        ),
                      ),
                      onPressed: isDisabled
                          ? null
                          : () async {
                              authVM.clearErrors();
                              final success = await authVM.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                              if (!mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logged in successfully!'),
                                    backgroundColor:
                                        Color.fromARGB(255, 102, 177, 104),
                                  ),
                                );
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: authVM.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Log In',
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required bool hasError,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fieldColor,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: hasError ? errorColor : fieldColor, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: hasError ? errorColor : focusedColor, width: 1.8),
      ),
    );
  }

  Widget _errorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 8),
        child: Text(
          text,
          style: TextStyle(color: errorColor, fontSize: 13),
        ),
      );
}


