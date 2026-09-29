import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';

class ElderHospitalDocumentsScreen extends StatelessWidget {
  final String elderId;

  const ElderHospitalDocumentsScreen({
    super.key,
    required this.elderId,
  });

  Future<void> _openDocument(
    BuildContext context,
    String? filePath,
  ) async {
    if (filePath == null || filePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This document does not have a valid file.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final String url =
          SupabaseService.getHospitalDocumentUrl(
        filePath,
      );

      final Uri uri = Uri.parse(url);

      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the document.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open document:\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore =
        FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),

      appBar: AppBar(
        title: const Text(
          'Hospital Documents',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color(0xFFFFF9F1),
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('elders')
            .doc(elderId)
            .collection('hospitalDocuments')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),

        builder: (
          BuildContext context,
          AsyncSnapshot<
                  QuerySnapshot<Map<String, dynamic>>>
              snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF21866A),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load hospital documents.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 70,
                      color: Color(0xFF21866A),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hospital documents',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF173B36),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Documents uploaded by your caregiver '
                      'will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF60736E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F4EC),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.folder_shared_rounded,
                      size: 42,
                      color: Color(0xFF21866A),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Medical Documents',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF173B36),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Documents uploaded by your caregiver.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF60736E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ...documents.map(
                (
                  QueryDocumentSnapshot<
                          Map<String, dynamic>>
                      document,
                ) {
                  final data = document.data();

                  final String title =
                      data['title']?.toString() ??
                          'Hospital Document';

                  final String type =
                      data['type']?.toString() ??
                          'Medical Document';

                  final String fileName =
                      data['fileName']?.toString() ??
                          'Document';

                  final String? filePath =
                      data['filePath']?.toString();

                  final String extension =
                      data['fileExtension']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  final bool isPdf =
                      extension == 'pdf' ||
                      fileName
                          .toLowerCase()
                          .endsWith('.pdf');

                  return _ElderDocumentCard(
                    title: title,
                    type: type,
                    fileName: fileName,
                    isPdf: isPdf,
                    onOpen: () {
                      _openDocument(
                        context,
                        filePath,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ElderDocumentCard extends StatelessWidget {
  final String title;
  final String type;
  final String fileName;
  final bool isPdf;
  final VoidCallback onOpen;

  const _ElderDocumentCard({
    required this.title,
    required this.type,
    required this.fileName,
    required this.isPdf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: isPdf
                      ? const Color(0xFFFFE1E1)
                      : const Color(0xFFE1F4EA),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.image_rounded,
                  size: 30,
                  color: isPdf
                      ? Colors.red
                      : const Color(0xFF21866A),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF173B36),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF21866A),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      fileName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF60736E),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF21866A),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}