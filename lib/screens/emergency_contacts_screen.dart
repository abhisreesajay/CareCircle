import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  bool _isLoading = false;

  User? get _currentUser {
    return _auth.currentUser;
  }

  String? get _userId {
    return _currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _contactsCollection {
    return _firestore.collection('emergencyContacts');
  }

  // Opens the login/register screen
  Future<void> _openLoginScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  Future<void> _showAddContactDialog() async {
    final userId = _userId;

    if (userId == null) {
      await _openLoginScreen();
      return;
    }

    _nameController.clear();
    _phoneController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact name',
                  hintText: 'Enter contact name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: 'Enter phone number',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name =
                    _nameController.text.trim();

                final phone =
                    _phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter both name and phone number',
                      ),
                    ),
                  );
                  return;
                }

                if (phone.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid phone number',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await _contactsCollection.add({
                    'userId': userId,
                    'name': name,
                    'phone': phone,
                    'createdAt':
                        FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Emergency contact saved successfully',
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to save contact: $error',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(String documentId) async {
    final userId = _userId;

    if (userId == null) {
      await _openLoginScreen();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _contactsCollection
          .doc(documentId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Emergency contact deleted',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete contact: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteContact(
    String documentId,
    String contactName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Contact?'),
          content: Text(
            'Are you sure you want to delete $contactName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteContact(documentId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    // Screen shown when the user is not logged in
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Contacts'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please login to manage emergency contacts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 20),

                // This button now opens AuthScreen
                ElevatedButton(
                  onPressed: _openLoginScreen,
                  child: const Text('LOGIN REQUIRED'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Screen shown after login
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
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
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

          if (documents.isEmpty) {
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
                  data['name']?.toString() ?? 'Unknown';

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
      ),
    );
  }
}