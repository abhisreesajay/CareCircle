
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/emergency_contact_model.dart';
import '../../services/caregiver/emergency_contact_service.dart';

class ElderEmergencyContactsScreen extends StatelessWidget {
  final String elderId;

  const ElderEmergencyContactsScreen({
    super.key,
    required this.elderId,
  });

  static const Color background = Color(0xFFF7F8FA);
  static const Color textColor = Color(0xFF111111);
  static const Color muted = Color(0xFF62666D);
  static const Color green = Color(0xFF009E60);
  static const Color greenLight = Color(0xFFE4F8EC);

  Future<void> _callContact(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final String phone = contact.phone.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This contact has no phone number.'),
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final bool opened = await launchUrl(phoneUri);

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the phone dialer.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the phone dialer.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<EmergencyContact>>(
          stream: EmergencyContactService().getContacts(elderId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Unable to load emergency contacts.\n'
                    'Please try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: muted,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final contacts = snapshot.data ?? [];

            if (contacts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contact_phone_rounded,
                        size: 64,
                        color: green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No emergency contacts yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ask your caregiver to add emergency '
                        'contacts for you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: greenLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded,
                        color: green,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap Call to open your phone dialer '
                          'and contact someone you trust.',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...contacts.map(
                  (contact) => Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: greenLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: green,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.name.isEmpty
                                          ? 'Emergency Contact'
                                          : contact.name,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      contact.relationship.isEmpty
                                          ? 'Trusted contact'
                                          : contact.relationship,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: muted,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      contact.phone.isEmpty
                                          ? 'No phone number saved'
                                          : contact.phone,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: contact.phone.trim().isEmpty
                                  ? null
                                  : () => _callContact(context, contact),
                              icon: const Icon(
                                Icons.call_rounded,
                                size: 21,
                              ),
                              label: const Text(
                                'Call Contact',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}