import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visualguide/IAM/services/auth_service.dart';

class LoginEmailForm extends StatefulWidget {
  const LoginEmailForm({super.key});

  @override
  State<LoginEmailForm> createState() => _LoginEmailForm();
}

class _LoginEmailForm extends State<LoginEmailForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor ingresa tu email y contraseña")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response =
          await AuthService.loginUser(email: email, password: password);

      // Aquí recibes el token y los datos del usuario
      final token = response["token"];
      final user = response["user"];

      if (token != null) {
        // Aquí podrías guardar el token en almacenamiento seguro si lo deseas
        // Ejemplo: await SecureStorage().saveToken(token);

        _showSuccessDialog("Bienvenido, ${user["name"]}!");
      } else {
        _showErrorDialog("Error: respuesta inválida del servidor.");
      }
    } catch (e) {
      _showErrorDialog('Credenciales inválidas.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF239B56), size: 70),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF239B56),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF239B56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                child: const Text("Continuar",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
                value: true,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
                activeColor: const Color(0xFF239B56)),
            const Text('Remember me'),
          ],
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF239B56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(0, 0),
                ),
                onPressed: _handleLogin,
                child: const Text('Continue',
                    style: TextStyle(color: Colors.white)),
              ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Forgot my password',
            style: TextStyle(color: Color(0xFF239B56)),
          ),
        ),
      ],
    );
  }
}
