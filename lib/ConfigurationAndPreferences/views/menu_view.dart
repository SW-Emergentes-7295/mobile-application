import 'package:flutter/material.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {
        'title': 'Family Control Panel',
        'icon': Icons.home_filled,
        'route': '/family_control_panel',
      },
      {
        'title': 'Link with a Caregiver (QR)',
        'icon': Icons.qr_code_2,
        'route': '/link_with_a_caregiver_qr',
      },
      {
        'title': 'Link with a Caregiver',
        'icon': Icons.link,
        'route': '/link_with_a_caregiver',
      },
      {
        'title': 'Trip History',
        'icon': Icons.history,
        'route': '/trip_history',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisualGuide Menu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: menuOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final option = menuOptions[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, option['route']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(option['icon'], color: Colors.green[700], size: 40),
                    const SizedBox(height: 10),
                    Text(
                      option['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
