import 'package:flutter/material.dart';

class SignupEmailForm extends StatelessWidget {
  const SignupEmailForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm your password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• At least one uppercase and lowercase\n'
          '• At least a number\n'
          '• At least a special character\n'
          '• At least 8 characters',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(value: false, onChanged: (_) {}),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: "I've read and accept the "),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(color: Color(0xFF239B56)),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: TextStyle(color: Color(0xFF239B56)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF239B56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(0, 0),
          ),
          onPressed: () {},
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
