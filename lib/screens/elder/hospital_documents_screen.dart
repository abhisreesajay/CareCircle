import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class HospitalDocumentsScreen extends StatelessWidget {
  final String elderId;

  const HospitalDocumentsScreen({
    super.key,
    required this.elderId,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _documentsStream() {
    return FirebaseFirestore.instance
        .collection('elders')
        .doc(elderId)
        .collection('hospitalDocuments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (elderId.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hospital Documents'),
        ),
        body: const Center(
          child: Text(
            'Unable to identify your account.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Theme(
      data: elderTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hospital Documents',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _documentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ElderColors.secondary,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message:
                    'Unable to load hospital documents.',
                details:
                    '${snapshot.error}',
              );
            }

            final documents =
                snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return const _EmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document =
                    documents[index];

                final data = document.data();

                final String title =
                    data['title']?.toString() ??
                        'Hospital Document';

                final String description =
                    data['description']?.toString() ??
                        '';

                final String documentType =
                    data['type']?.toString() ??
                        'Medical Document';

                final String url =
                    data['url']?.toString() ?? '';

                return _DocumentCard(
                  title: title,
                  description: description,
                  documentType: documentType,
                  url: url,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String description;
  final String documentType;
  final String url;

  const _DocumentCard({
    required this.title,
    required this.description,
    required this.documentType,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ElderColors.secondary
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: ElderColors.secondary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              documentType,
              style: const TextStyle(
                color: ElderColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: ElderColors.mutedText,
                ),
              ),
            ],
            if (url.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Document link:\n$url',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.open_in_new,
                  ),
                  label: const Text(
                    'VIEW DOCUMENT',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 80,
              color: ElderColors.secondary,
            ),
            SizedBox(height: 20),
            Text(
              'No hospital documents yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your caregiver can add hospital documents for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ElderColors.mutedText,
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
  final String details;

  const _ErrorState({
    required this.message,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: ElderColors.critical,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ElderColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}