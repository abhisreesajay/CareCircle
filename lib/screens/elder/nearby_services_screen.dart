import 'package:flutter/material.dart';

class ElderNearbyServicesScreen extends StatelessWidget {
  const ElderNearbyServicesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE5),
      appBar: AppBar(
        title: const Text('Nearby Services'),
        backgroundColor: const Color(0xFF46695A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'What are you looking for?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26352F),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose a nearby service.',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF66756E),
            ),
          ),

          const SizedBox(height: 24),

          _ServiceCard(
            icon: Icons.local_hospital_outlined,
            title: 'Hospitals',
            subtitle: 'Find hospitals and care centres nearby',
          ),

          const SizedBox(height: 14),

          _ServiceCard(
            icon: Icons.storefront_outlined,
            title: 'Shops',
            subtitle: 'Find nearby shops',
          ),

          const SizedBox(height: 14),

          _ServiceCard(
            icon: Icons.restaurant_outlined,
            title: 'Restaurants',
            subtitle: 'Find nearby restaurants',
          ),

          const SizedBox(height: 14),

          _ServiceCard(
            icon: Icons.medical_services_outlined,
            title: 'Care Centres',
            subtitle: 'Find nearby care centres',
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF46695A),
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nearby locations will be connected to the map service.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF46695A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFBF4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0ED),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFF46695A),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26352F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF66756E),
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