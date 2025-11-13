import 'package:flutter/material.dart';
import 'package:visualguide/IAM/services/auth_service.dart';

class SignupEmailForm extends StatefulWidget {
  const SignupEmailForm({super.key});

  @override
  State<SignupEmailForm> createState() => _SignupEmailFormState();
}

class _SignupEmailFormState extends State<SignupEmailForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _termsAccepted = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor completa todos los campos obligatorios")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Debes aceptar los términos y condiciones")),
        );
        return;
      }

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor ingresa un email válido")),
        );
        return;
      }

      final user = await AuthService.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF239B56), size: 28),
              SizedBox(width: 10),
              Text(
                "Cuenta creada",
                style: TextStyle(
                  color: Color(0xFF239B56),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Tu cuenta fue creada exitosamente.",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el modal
                Navigator.pushReplacementNamed(
                    context, '/welcome'); // Va al login
              },
              child: const Text(
                "Continuar",
                style: TextStyle(color: Color(0xFF239B56)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmController,
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
            Checkbox(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() => _termsAccepted = value ?? false);
                }),
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
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
