import 'package:flutter/material.dart';
import 'login_email_form.dart';
import 'signup_email_form.dart';

class LoginEmailTabs extends StatefulWidget {
  const LoginEmailTabs({super.key});

  @override
  State<LoginEmailTabs> createState() => _LoginEmailTabsState();
}

class _LoginEmailTabsState extends State<LoginEmailTabs>
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
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF239B56),
        elevation: 0,
        title: const Text('VisualGuide', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome to VisualGuide',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF239B56)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
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
                Tab(text: 'Log in'),
                Tab(text: 'Sign up'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  LoginEmailForm(),
                  SignupEmailForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
