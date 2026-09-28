import 'package:flutter/material.dart';
import '../../services/elder_status_service.dart';

class ElderStatusScreen extends StatelessWidget {
  final String elderId;

  const ElderStatusScreen({
    super.key,
    required this.elderId,
  });

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

  @override
  Widget build(BuildContext context) {
    final service = ElderStatusService();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Elder Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: service.getStatus(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 55,
                      color: darkGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load elder status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final document = snapshot.data;

          if (document == null || !document.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 65,
                      color: primaryGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Elder status not available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = document.data() ?? {};

          final checkInStatus =
              data['checkInStatus'] ?? 'Not available';

          final safeZoneStatus =
              data['safeZoneStatus'] ?? 'Not available';

          final medicineStatus =
              data['medicineStatus'] ?? 'Not available';

          final lastActivity =
              data['lastActivity'] ?? 'Not available';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statusCard(
                  icon: Icons.check_circle_outline,
                  title: 'Check-in',
                  value: checkInStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.home_outlined,
                  title: 'Safe Zone',
                  value: safeZoneStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.medication_outlined,
                  title: 'Medicine',
                  value: medicineStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.access_time,
                  title: 'Last Activity',
                  value: lastActivity.toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: darkGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}