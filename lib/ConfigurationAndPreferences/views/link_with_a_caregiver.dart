import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'link_with_a_caregiver_qr.dart';

class LinkWithACaregiver extends StatefulWidget {
  const LinkWithACaregiver({super.key});

  @override
  State<LinkWithACaregiver> createState() => _LinkWithACaregiverState();
}

class _LinkWithACaregiverState extends State<LinkWithACaregiver> {
  bool _loading = false;
  String? _message;
  String? _linkCode;

  Future<void> _generateLink() async {
    setState(() {
      _loading = true;
      _message = null;
      _linkCode = null;
    });

    final body = {"blind_user_id": "U001"}; // Ejemplo de usuario

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/configuration/generate-link"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = data["message"];
          _linkCode = data["link_code"];
        });
      } else {
        setState(() {
          _message = "Error al generar el vínculo (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error de conexión con el servidor";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF008037),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.remove_red_eye, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'VisualGuide',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Link with a\nCaregiver',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Allow a trusted family member to\nfollow your activity and assist you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 340,
                height: 270,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/link_caregiver.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _loading ? null : _generateLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 4,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Generate linking code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              if (_linkCode != null) ...[
                const SizedBox(height: 30),
                const Text(
                  'Generated Link Code:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _linkCode!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LinkWithACaregiverQR()),
                  );
                },
                child: const Text(
                  'Scan QR instead',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
