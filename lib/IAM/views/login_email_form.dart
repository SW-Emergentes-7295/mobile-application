import 'package:flutter/material.dart';

class LoginEmailForm extends StatelessWidget {
  const LoginEmailForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(value: true, onChanged: (_) {}),
            const Text('Remember me'),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF239B56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {},
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Forgot my password',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
