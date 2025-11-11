import 'package:flutter/material.dart';

class LoginCamera extends StatefulWidget {
  const LoginCamera({super.key});

  @override
  State<LoginCamera> createState() => _LoginCameraState();
}

class _LoginCameraState extends State<LoginCamera>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF239B56),
        elevation: 0,
        title: const Text(
          'VisualGuide',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Welcome to VisualGuide',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF239B56)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'To use the app, please log in or register with a new account. Don’t worry, signing in is very easy!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF239B56),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF239B56),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(
                  text: 'Log in',
                ),
                Tab(
                  text: 'Sign up',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Look directly into the camera to identify yourself',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 180,
              width: 180,
              child: Image.asset(
                  'assets/images/face_scan.png'), // cambia a tu asset
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF239B56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  // Aquí irá la lógica de reconocimiento facial o login
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navegar a login por correo
              },
              child: const Text(
                'Sign in with my email',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
