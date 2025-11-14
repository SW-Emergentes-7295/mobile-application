import 'package:flutter/material.dart';

class FamilyControlPanel extends StatelessWidget {
  const FamilyControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'VisualGuide',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'FAMILY CONTROL\nPANEL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            //casa imagen estatica
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/floorplan.png',
                width: double.infinity,
                height: 260,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            //microfono botones
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF757575),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                const Text(
                  'SPEAK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-Time Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• Last location: Kitchen',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('• Activity: Slow movement detected',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('• Device battery: 34%',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 20),
                  Text(
                    'Recent Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• Activity of Slow movement: 2 min ago',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.redAccent, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Possible obstacle, a chair in the kitchen doorway: 10 min ago',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Stable connection',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
