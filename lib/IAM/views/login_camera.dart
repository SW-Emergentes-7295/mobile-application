import 'package:flutter/material.dart';
import 'package:visualguide/IAM/views/login_email_form.dart';
import 'package:visualguide/IAM/views/signup_email_form.dart';

class LoginCamera extends StatefulWidget {
  const LoginCamera({super.key});

  @override
  State<LoginCamera> createState() => _LoginCameraState();
}

class _LoginCameraState extends State<LoginCamera>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool useEmailLogin = false;

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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'VisualGuide',
                style: TextStyle(color: Colors.white),
              ),
            ],
          )),
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
              textAlign: TextAlign.start,
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
            Expanded(
                child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: useEmailLogin ? _buildEmailTabs() : _buildCameraContent(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    return Column(
      key: const ValueKey('cameraView'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Look directly into the camera to identify yourself',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 180,
          width: 180,
          child: Image.asset('assets/images/face-id.png'),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: const Size(0, 0),
            ),
            onPressed: () {
              // Aquí irá la lógica de reconocimiento facial
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
            setState(() {
              useEmailLogin = true;
            });
          },
          child: const Text(
            'Sign in with my email',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  // 📧 Modo 2: Formularios de login/sign up
  Widget _buildEmailTabs() {
    return TabBarView(
      key: const ValueKey('emailView'),
      controller: _tabController,
      children: const [
        LoginEmailForm(),
        SignupEmailForm(),
      ],
    );
  }
}
