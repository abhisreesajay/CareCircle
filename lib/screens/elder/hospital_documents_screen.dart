import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';

class HospitalDocumentsScreen extends StatefulWidget {
  final String elderId;

  const HospitalDocumentsScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<HospitalDocumentsScreen> createState() =>
      _HospitalDocumentsScreenState();
}

class _HospitalDocumentsScreenState
    extends State<HospitalDocumentsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _documentsCollection {
    return _firestore
        .collection('elders')
        .doc(widget.elderId)
        .collection('hospitalDocuments');
  }

  Future<void> _openDocument(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) {
      _showMessage(
        'Document file is unavailable.',
        isError: true,
      );
      return;
    }

    try {
      final String url =
          SupabaseService.getHospitalDocumentUrl(
        filePath,
      );

      final Uri uri = Uri.parse(url);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage(
          'Could not open the document.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not open document:\n$e',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),

      appBar: AppBar(
        title: const Text(
          'Hospital Documents',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFFFF9F1),
        foregroundColor: const Color(0xFF173B36),
        elevation: 0,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _documentsCollection
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 55,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load documents.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildHeader(documents.length),

              const SizedBox(height: 20),

              ...documents.map(
                (
                  QueryDocumentSnapshot<
                          Map<String, dynamic>>
                      document,
                ) {
                  final data = document.data();

                  return _ElderDocumentTile(
                    title:
                        data['title']?.toString() ??
                            'Hospital Document',

                    type:
                        data['type']?.toString() ??
                            'Medical Document',

                    fileName:
                        data['fileName']?.toString() ??
                            'File',

                    fileExtension:
                        data['fileExtension']
                                ?.toString() ??
                            '',

                    onOpen: () {
                      _openDocument(
                        data['filePath']?.toString(),
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

  Widget _buildHeader(int documentCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4EC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF21866A),
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.folder_shared_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Medical Documents',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF173B36),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  documentCount == 1
                      ? '1 document available'
                      : '$documentCount documents available',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF60736E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F4EC),
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: Color(0xFF21866A),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Documents Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Color(0xFF173B36),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your caregiver has not uploaded any hospital documents yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF60736E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElderDocumentTile extends StatelessWidget {
  final String title;
  final String type;
  final String fileName;
  final String fileExtension;
  final VoidCallback onOpen;

  const _ElderDocumentTile({
    required this.title,
    required this.type,
    required this.fileName,
    required this.fileExtension,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPdf =
        fileExtension.toLowerCase() == 'pdf' ||
            fileName.toLowerCase().endsWith('.pdf');

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
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
                  color: isPdf
                      ? Colors.red
                      : const Color(0xFF21866A),
                  size: 29,
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
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173B36),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF60736E),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A9691),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF21866A),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}