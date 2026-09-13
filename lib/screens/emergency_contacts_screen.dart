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
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: StreamBuilder<List<EmergencyContact>>(
        stream: _contactService.getContacts(
          widget.elderId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const Center(
              child: Text(
                'No emergency contacts added yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.contact_phone,
                    size: 35,
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${contact.phone}\n'
                    '${contact.relationship}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
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
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
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
        onPressed: () {
          _showContactDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}