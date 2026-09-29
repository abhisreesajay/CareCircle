import 'package:flutter/material.dart';

import '../../models/emergency_contact_model.dart';
import '../../services/caregiver/emergency_contact_service.dart';

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

<<<<<<< HEAD
  static const Color cream = Color(0xFFF4EFE5);
  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color cardCream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  Future<void> _showContactDialog({
    EmergencyContact? contact,
  }) async {
    final nameController = TextEditingController(
      text: contact?.name ?? '',
    );

    final phoneController = TextEditingController(
      text: contact?.phone ?? '',
    );

    final relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            contact == null
                ? 'Add emergency contact'
                : 'Edit emergency contact',
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
=======
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
>>>>>>> develop
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
<<<<<<< HEAD
                _DialogField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline_rounded,
                  hint: 'e.g. Anu',
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  hint: 'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: relationshipController,
                  label: 'Relationship',
                  icon: Icons.people_outline_rounded,
                  hint: 'e.g. Daughter',
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
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
>>>>>>> develop
=======
>>>>>>> origin/main
                ),
              ],
            ),
          ),
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        ),
      );
    }

    // User is logged in.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _contactsCollection
            .where(
              'userId',
              isEqualTo: userId,
            )
            .snapshots(),
=======
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
=======
          actionsPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
>>>>>>> origin/main
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
<<<<<<< HEAD
                style: TextStyle(color: mutedText),
=======
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
>>>>>>> develop
=======
                style: TextStyle(
                  color: mutedText,
                ),
>>>>>>> origin/main
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                backgroundColor: darkSage,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final relationship =
                    relationshipController.text.trim();

                if (name.isEmpty ||
                    phone.isEmpty ||
                    relationship.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill in all fields.',
                      ),
                    ),
                  );
=======
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
>>>>>>> develop
                  return;
                }

                final newContact = EmergencyContact(
                  id: contact?.id ??
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                  name: name,
                  phone: phone,
                  relationship: relationship,
                );

<<<<<<< HEAD
                try {
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

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        contact == null
                            ? 'Emergency contact added'
                            : 'Emergency contact updated',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $e',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                contact == null ? 'Add' : 'Save',
=======
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
>>>>>>> develop
              ),
            ),
          ],
        );
      },
    );
<<<<<<< HEAD

    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
  }

  Future<void> _deleteContact(
    EmergencyContact contact,
  ) async {
    try {
      await _contactService.deleteContact(
        widget.elderId,
        contact.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Emergency contact deleted',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting contact: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    EmergencyContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete contact?',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '${contact.name} will be removed from the emergency contacts.',
            style: const TextStyle(
              color: mutedText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: mutedText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: terracotta,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteContact(contact);
    }
=======
  }

  Future<void> _deleteContact(String contactId) async {
    await _contactService.deleteContact(
      widget.elderId,
      contactId,
    );
>>>>>>> develop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactDialog();
        },
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add contact',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<EmergencyContact>>(
<<<<<<< HEAD
        stream: _contactService.getContacts(widget.elderId),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
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
>>>>>>> develop
=======
        stream: _contactService.getContacts(
          widget.elderId,
        ),
>>>>>>> origin/main
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
<<<<<<< HEAD
                color: darkSage,
=======
                color: primaryGreen,
>>>>>>> develop
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading contacts:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

<<<<<<< HEAD
          if (documents.isEmpty) {
=======
          if (contacts.isEmpty) {
>>>>>>> develop
            return const Center(
              child: Text(
                'No emergency contacts added yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final String name =
                  data['name']?.toString() ??
                      'Unknown';

              final String phone =
                  data['phone']?.toString() ??
                      'No phone number';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(name),
                  subtitle: Text(phone),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
<<<<<<< HEAD
                    onPressed: _isLoading
                        ? null
                        : () {
                            _confirmDeleteContact(
                              document.id,
                              name,
                            );
                          },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
=======
=======
>>>>>>> origin/main
            return const _ErrorState(
              message: 'Could not load emergency contacts.',
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const _EmptyState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              110,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkSage,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.14,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your care circle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${contacts.length} emergency contact'
                            '${contacts.length == 1 ? '' : 's'} available',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Emergency contacts',
                style: TextStyle(
                  color: textDark,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ...contacts.map(
                (contact) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: _ContactCard(
                    contact: contact,
                    onEdit: () {
                      _showContactDialog(
                        contact: contact,
                      );
                    },
                    onDelete: () {
                      _confirmDelete(contact);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color cardCream = Color(0xFFFFFBF4);
  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: sage.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: sage.withValues(
                      alpha: 0.16,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: darkSage,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: sage.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          contact.relationship,
                          style: const TextStyle(
                            color: darkSage,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
=======
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
>>>>>>> develop
                        ),
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                PopupMenuButton<String>(
                  color: cardCream,
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                          ),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                          ),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: sage.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: darkSage,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      contact.phone,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: terracotta,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: 18,
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

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
  });

  static const Color darkSage = Color(0xFF46695A);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: darkSage,
        ),
        labelStyle: const TextStyle(
          color: darkSage,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: darkSage,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color darkSage = Color(0xFF46695A);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: darkSage.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.contacts_outlined,
                size: 42,
                color: darkSage,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No emergency contacts',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: darkSage,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add trusted contacts who can be reached when needed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  static const Color terracotta = Color(0xFFC85C50);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: terracotta,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: terracotta,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
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
>>>>>>> develop
=======
>>>>>>> origin/main
      ),
    );
  }
}