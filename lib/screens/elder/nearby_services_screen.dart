import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/nearby_service_model.dart';
import '../../services/caregiver/nearby_service_service.dart';

class ElderNearbyServicesScreen extends StatelessWidget {
  const ElderNearbyServicesScreen({super.key});

  static const Color background = Color(0xFFF7F5EF);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in again.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final service = NearbyServiceService();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          'Nearby Services',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<NearbyService>>(
        stream: service.getServices(user.uid),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message:
                  'Unable to load nearby services.\n\n${snapshot.error}',
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const _EmptyServices();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),
            children: [
              // ----------------------------------------------------------
              // HEADER
              // ----------------------------------------------------------

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      darkSage,
                      Color(0xFF5E7B68),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: darkSage.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 29,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Nearby care & services',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Find hospitals, shops, restaurants and care centres saved for you by your caregiver.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ----------------------------------------------------------
              // CATEGORY SUMMARY
              // ----------------------------------------------------------

              _CategorySummary(
                services: services,
              ),

              const SizedBox(height: 18),

              const Text(
                'Saved Places',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Places your caregiver has added for you',
                style: TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),

              const SizedBox(height: 14),

              // ----------------------------------------------------------
              // SERVICES
              // ----------------------------------------------------------

              ...services.map(
                (item) => _ServiceCard(
                  service: item,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ========================================================================
// CATEGORY SUMMARY
// ========================================================================

class _CategorySummary extends StatelessWidget {
  final List<NearbyService> services;

  const _CategorySummary({
    required this.services,
  });

  int _countType(
    String type,
  ) {
    return services.where(
      (service) {
        final value = service.type.toLowerCase();

        return value == type ||
            value == '${type}s' ||
            (type == 'hospital' && value == 'hospitals') ||
            (type == 'shop' && value == 'shops') ||
            (type == 'restaurant' && value == 'restaurants') ||
            (type == 'care centre' &&
                (value == 'care center' ||
                    value == 'care centres'));
      },
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = services.where((service) {
      final type = service.type.toLowerCase();
      return type == 'hospital' || type == 'hospitals';
    }).length;

    final shops = services.where((service) {
      final type = service.type.toLowerCase();
      return type == 'shop' || type == 'shops';
    }).length;

    final restaurants = services.where((service) {
      final type = service.type.toLowerCase();
      return type == 'restaurant' || type == 'restaurants';
    }).length;

    final careCentres = services.where((service) {
      final type = service.type.toLowerCase();
      return type == 'care centre' ||
          type == 'care center' ||
          type == 'care centres';
    }).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            icon: Icons.local_hospital_rounded,
            label: 'Hospitals',
            count: hospitals,
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            icon: Icons.storefront_rounded,
            label: 'Shops',
            count: shops,
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            icon: Icons.restaurant_rounded,
            label: 'Food',
            count: restaurants,
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            icon: Icons.medical_services_rounded,
            label: 'Care',
            count: careCentres,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5E1D7),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF46695A),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352F),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF46695A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// SERVICE CARD
// ========================================================================

class _ServiceCard extends StatelessWidget {
  final NearbyService service;

  const _ServiceCard({
    required this.service,
  });

  IconData _iconForType() {
    switch (service.type.toLowerCase()) {
      case 'hospital':
      case 'hospitals':
        return Icons.local_hospital_rounded;

      case 'shop':
      case 'shops':
        return Icons.storefront_rounded;

      case 'restaurant':
      case 'restaurants':
        return Icons.restaurant_rounded;

      case 'care centre':
      case 'care center':
      case 'care centres':
        return Icons.medical_services_rounded;

      default:
        return Icons.place_rounded;
    }
  }

  Color _iconBackground() {
    switch (service.type.toLowerCase()) {
      case 'hospital':
      case 'hospitals':
        return const Color(0xFFFFE4DF);

      case 'shop':
      case 'shops':
        return const Color(0xFFE8E8F7);

      case 'restaurant':
      case 'restaurants':
        return const Color(0xFFFFEBD8);

      case 'care centre':
      case 'care center':
      case 'care centres':
        return const Color(0xFFE5F0EA);

      default:
        return const Color(0xFFE8EEE9);
    }
  }

  Color _iconColor() {
    switch (service.type.toLowerCase()) {
      case 'hospital':
      case 'hospitals':
        return const Color(0xFFC94B3D);

      case 'shop':
      case 'shops':
        return const Color(0xFF5E6295);

      case 'restaurant':
      case 'restaurants':
        return const Color(0xFFB86A32);

      case 'care centre':
      case 'care center':
      case 'care centres':
        return const Color(0xFF46695A);

      default:
        return const Color(0xFF46695A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 13,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFEAE5DA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------------
          // ICON
          // --------------------------------------------------------------

          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: _iconBackground(),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _iconForType(),
              color: _iconColor(),
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          // --------------------------------------------------------------
          // DETAILS
          // --------------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF26352F),
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _iconBackground(),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    service.type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _iconColor(),
                    ),
                  ),
                ),

                if (service.address.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Color(0xFF7A827D),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          service.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: Color(0xFF7A827D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (service.phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Color(0xFF46695A),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          service.phone,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF46695A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// EMPTY STATE
// ========================================================================

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F0EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 55,
                color: Color(0xFF46695A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No nearby services yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF26352F),
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Your caregiver can add hospitals, shops, restaurants and care centres for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF7A827D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// ERROR STATE
// ========================================================================

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFC94B3D),
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load services',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF26352F),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF7A827D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}