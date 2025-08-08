
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // 🌱 Customize: colors
  final Color backgroundColor = const Color(0xFF19485C);
  final Color fieldColor = const Color(0xFF287191);
  final Color focusedColor = Colors.white;
  final Color errorColor = const Color.fromARGB(255, 204, 203, 203);
  final Color buttonActiveColor = const Color.fromARGB(255, 10, 79, 102);
  final Color buttonDisabledColor = Colors.grey;
  final Color buttonBorderColor = const Color.fromARGB(202, 255, 255, 255);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get isFormFilled {
    final authVM = context.read<AuthViewModel>();
    return _usernameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text == _passwordController.text &&
           authVM.isPasswordValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          final bool isDisabled = authVM.isLoading || !isFormFilled;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Center(child: Text('Become part of Taskify family',
                    style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(height: 20),
                const Text('Sign Up', style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration(
                    hintText: 'Username',
                    icon: Icons.person,
                    hasError: authVM.usernameError != null,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (authVM.usernameError != null)
                  _errorText(authVM.usernameError!),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hintText: 'Email',
                    icon: Icons.email,
                    hasError: authVM.emailError != null,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                if (authVM.emailError != null)
                  _errorText(authVM.emailError!),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: _inputDecoration(
                    hintText: 'Password',
                    icon: Icons.lock,
                    hasError: authVM.passwordError != null,
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  onChanged: (value) => authVM.validatePassword(value),
                  style: const TextStyle(color: Colors.white),
                ),
                if (authVM.passwordError != null)
                  _errorText(authVM.passwordError!),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: _inputDecoration(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    hasError: _confirmPasswordController.text != _passwordController.text,
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}), // update confirm match check
                ),
                if (_confirmPasswordController.text != _passwordController.text)
                  _errorText('Passwords do not match'),
                const SizedBox(height: 30),

                // 🌱 Sign Up button with dynamic color & border
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white,
                        backgroundColor: isDisabled ? buttonDisabledColor : buttonActiveColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDisabled ? const Color.fromARGB(66, 134, 133, 133) : buttonBorderColor,
                            width: 1.8,
                          ),
                        ),
                      ),
                      onPressed: isDisabled
                          ? null
                          : () async {
                              authVM.clearErrors();
                              final success = await authVM.signUp(
                                _usernameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                              if (success && mounted) {
                                // 🌱 Show success snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Account created successfully!'),
                                    backgroundColor: Color.fromARGB(255, 102, 177, 104),
                                  ),
                                );
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: authVM.isLoading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign Up', style: TextStyle(fontSize: 16,color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

               Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      'Already have an account? ',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 17,
      ),
    ),
    GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: const Text(
        'Log In',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 17,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white
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
        borderSide: BorderSide(color: hasError ? errorColor : fieldColor, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: hasError ? errorColor : focusedColor, width: 1.8),
      ),
    );
  }

  Widget _errorText(String text) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 8),
    child: Text(text, style: TextStyle(color: errorColor, fontSize: 13)),
  );
}
