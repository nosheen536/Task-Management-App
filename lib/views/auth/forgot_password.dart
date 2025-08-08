
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  final Color backgroundColor = const Color(0xFF19485C);
  final Color fieldColor = const Color(0xFF287191);
  final Color textColor = Colors.white;
  final Color buttonActiveColor = const Color.fromARGB(255, 10, 79, 102);
  final Color buttonDisabledColor = Colors.grey;
  final Color buttonBorderColor = Colors.white;

  bool isSubmitting = false;
  bool isEmailValid = false;
  bool showEmailWarning = false;
  bool isFocused = false;

  late FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _emailFocusNode = FocusNode();
    _emailFocusNode.addListener(() {
      setState(() {
        isFocused = _emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final value = _emailController.text.trim();
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

    setState(() {
      isEmailValid = isValid;
      showEmailWarning = value.isNotEmpty && !isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          final bool isDisabled = isSubmitting || !isEmailValid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                const Column(
                      crossAxisAlignment:CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                      "Enter your registered email below and we'll send you a link to reset your password.",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Email Input
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldColor,
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isFocused ? Colors.white : Colors.transparent,
                        width: 1.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 1.8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                // Small white warning message
                if (showEmailWarning)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Invalid email format',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 30),

                // Send Link Button
                Center(
                  child: SizedBox(
                    width: 200,
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
                              setState(() => isSubmitting = true);
                              final success = await authVM.sendPasswordResetEmail(
                                _emailController.text.trim(),
                              );
                              setState(() => isSubmitting = false);

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password reset link sent to your email.',
                                    ),
                                    backgroundColor: Color.fromARGB(255, 102, 177, 104),
                                  ),
                                );
                                Navigator.pop(context);
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to send reset email. Try again.'),
                                    backgroundColor: Color.fromARGB(255, 247, 63, 63),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Send Link',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(232, 238, 230, 230)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


