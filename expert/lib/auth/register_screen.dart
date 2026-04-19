import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E4CB9),
                  ),
                ),
                const SizedBox(height: 40),
                _inputField('Email'),
                const SizedBox(height: 20),
                _inputField('Password', isPassword: true),
                const SizedBox(height: 20),
                _inputField('Confirm Password', isPassword: true),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Action sign up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4CB9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sign up', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 25),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text('Or continue with', style: TextStyle(color: Color(0xFF2E4CB9), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon(Icons.g_mobiledata, size: 35),
                    const SizedBox(width: 15),
                    _socialIcon(Icons.facebook, size: 24),
                    const SizedBox(width: 15),
                    _socialIcon(Icons.apple, size: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: hintText == 'Email' ? Colors.blue.shade200 : Colors.transparent, width: hintText == 'Email' ? 1.5 : 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: hintText == 'Email' ? Colors.blue.shade200 : Colors.transparent, width: hintText == 'Email' ? 1.5 : 0),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, {double size = 24}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, color: Colors.black87, size: size)),
    );
  }
}
