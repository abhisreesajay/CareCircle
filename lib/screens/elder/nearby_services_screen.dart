import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/nearby_service_model.dart';
import '../../services/caregiver/nearby_service_service.dart';

class ElderNearbyServicesScreen
    extends StatelessWidget {
  const ElderNearbyServicesScreen({
    super.key,
  });

  static const Color background =
      Color(0xFFF4EFE5);

  static const Color cream =
      Color(0xFFFFFBF4);

  static const Color darkSage =
      Color(0xFF46695A);

  static const Color sage =
      Color(0xFF7FA68F);

  static const Color textDark =
      Color(0xFF26352F);

  static const Color mutedText =
      Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in again.',
          ),
        ),
      );
    }

    final service =
        NearbyServiceService();

    return Scaffold(
      backgroundColor:
          background,
      appBar: AppBar(
        backgroundColor:
            background,
        foregroundColor:
            textDark,
        elevation: 0,
        title: const Text(
          'Nearby Services',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          List<NearbyService>>(
        stream: service.getServices(
          user.uid,
        ),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load services:\n${snapshot.error}',
                textAlign:
                    TextAlign.center,
              ),
            );
          }

          final services =
              snapshot.data ?? [];

          if (services.isEmpty) {
            return const _EmptyServices();
          }

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(22),
                decoration:
                    BoxDecoration(
                  color: darkSage,
                  borderRadius:
                      BorderRadius.circular(
                    26,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      Icons
                          .location_on_rounded,
                      color:
                          Colors.white,
                      size: 34,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Nearby care',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Services saved by your caregiver are shown here.',
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              ...services.map(
                (item) =>
                    _ServiceCard(
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

class _ServiceCard
    extends StatelessWidget {
  final NearbyService service;

  const _ServiceCard({
    required this.service,
  });

  IconData _iconForType() {
    switch (service.type
        .toLowerCase()) {
      case 'hospital':
      case 'hospitals':
        return Icons
            .local_hospital_rounded;

      case 'shop':
      case 'shops':
        return Icons
            .storefront_rounded;

      case 'restaurant':
      case 'restaurants':
        return Icons
            .restaurant_rounded;

      case 'care centre':
      case 'care center':
      case 'care centres':
        return Icons
            .medical_services_rounded;

      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFBF4),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFE5F0EA),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child: Icon(
              _iconForType(),
              color:
                  const Color(
                0xFF46695A,
              ),
              size: 28,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  service.name,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(
                      0xFF26352F,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  service.type,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF46695A,
                    ),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                if (service.address
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    service.address,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF7A827D,
                      ),
                    ),
                  ),
                ],
                if (service.phone
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    service.phone,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF46695A,
                      ),
                      fontWeight:
                          FontWeight.w700,
                    ),
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

class _EmptyServices
    extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .location_off_rounded,
              size: 70,
              color:
                  Color(0xFF7FA68F),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'No nearby services saved yet.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF26352F),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Your caregiver can add hospitals, shops, restaurants and care centres.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Color(0xFF7A827D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}