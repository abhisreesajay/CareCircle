import 'package:flutter/material.dart';
import '../models/emergency_contact_model.dart';
import '../services/emergency_contact_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final String elderId;

  const EmergencyContactsScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final EmergencyContactService _contactService =
      EmergencyContactService();

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

  void _showContactDialog({EmergencyContact? contact}) {
    final nameController =
        TextEditingController(text: contact?.name ?? '');
    final phoneController =
        TextEditingController(text: contact?.phone ?? '');
    final relationshipController =
        TextEditingController(text: contact?.relationship ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            contact == null
                ? 'Add Emergency Contact'
                : 'Edit Emergency Contact',
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: const Icon(
                      Icons.people,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkGreen,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }

                final newContact = EmergencyContact(
                  id: contact?.id ??
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  relationship:
                      relationshipController.text.trim(),
                );

                if (contact == null) {
                  await _contactService.addContact(
                    widget.elderId,
                    newContact,
                  );
                } else {
                  await _contactService.updateContact(
                    widget.elderId,
                    newContact,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                contact == null ? 'Add' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(String contactId) async {
    await _contactService.deleteContact(
      widget.elderId,
      contactId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<EmergencyContact>>(
        stream: _contactService.getContacts(
          widget.elderId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: darkGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_phone_outlined,
                    size: 70,
                    color: primaryGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No emergency contacts added yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap + to add an emergency contact.',
                    style: TextStyle(
                      color: darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Card(
                color: lightGreen,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.contact_phone,
                      size: 28,
                      color: darkGreen,
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${contact.phone}\n'
                      '${contact.relationship}',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: darkGreen,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showContactDialog(
                          contact: contact,
                        );
                      } else if (value == 'delete') {
                        _deleteContact(contact.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          _showContactDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}