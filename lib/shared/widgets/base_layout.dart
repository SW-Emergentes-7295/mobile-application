import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget childScreen; // The content of the screen
  final String? role; // User's role to define sidebar's list

  BaseLayout({required this.role, required this.childScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('VisualGuide'),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: FutureBuilder<List<Widget>>(
              future: _getSidebarOptions(context), // Updated to FutureBuilder
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading sidebar options'));
                } else {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: snapshot.data!,
                  );
                }
              },
            ),
          ),
        ),
        body: childScreen);
  }

  Future<List<Widget>> _getSidebarOptions(BuildContext context) async {
    if (role == '') {
      return [
        ListTile(
          leading: const Icon(Icons.stop),
          title: const Text('No current Routes for now'),
          subtitle: const Text('Login First :)'),
          onTap: () {},
        ),
      ];
    }

    if (role == 'ROLE_CAREGIVER') {
      return [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ];
    } else if (role == 'ROLE_BLIND_USER') {
      return [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ];
    } else {
      return [
        const ListTile(
          title: Text('No role'),
          subtitle: Text('Check code'),
        ),
      ];
    }
  }
}
