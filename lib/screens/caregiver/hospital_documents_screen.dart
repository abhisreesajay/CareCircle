import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';

class CaregiverHospitalDocumentsScreen extends StatefulWidget {
  final String elderId;

  const CaregiverHospitalDocumentsScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<CaregiverHospitalDocumentsScreen> createState() =>
      _CaregiverHospitalDocumentsScreenState();
}

class _CaregiverHospitalDocumentsScreenState
    extends State<CaregiverHospitalDocumentsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _selectedType = 'Hospital Report';

  Uint8List? _selectedBytes;
  String? _selectedFileName;
  String? _selectedFileExtension;

  bool _isUploading = false;

  static const int _maxFileSize = 900 * 1024;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK FILE
  // ============================================================

  Future<void> _pickFile() async {
    try {
        final List<PlatformFile> files =
            await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
            'pdf',
            'jpg',
            'jpeg',
            'png',
        ],
        );

        if (files.isEmpty) {
        return;
        }

        final PlatformFile file = files.first;

        final Uint8List bytes =
            await file.readAsBytes();

        if (bytes.length > _maxFileSize) {
        if (mounted) {
            _showMessage(
            'File is too large.\n\n'
            'Please select a PDF or image smaller than 900 KB.',
            isError: true,
            );
        }
        return;
        }

        final String extension =
            file.extension?.toLowerCase() ?? '';

        if (![
        'pdf',
        'jpg',
        'jpeg',
        'png',
        ].contains(extension)) {
        if (mounted) {
            _showMessage(
            'Only PDF, JPG, JPEG and PNG files are allowed.',
            isError: true,
            );
        }
        return;
        }

        if (!mounted) {
        return;
        }

        setState(() {
        _selectedBytes = bytes;
        _selectedFileName = file.name;
        _selectedFileExtension = extension;
        });
    } catch (e) {
        if (!mounted) {
        return;
        }

        _showMessage(
        'Could not select the file:\n$e',
        isError: true,
        );
    }
  }

  // ============================================================
  // UPLOAD DOCUMENT
  // ============================================================

  Future<void> _uploadDocument() async {
    final String title =
        _titleController.text.trim();

    final String description =
        _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Please enter a document title.',
        isError: true,
      );
      return;
    }

    if (_selectedBytes == null) {
      _showMessage(
        'Please select a PDF or image.',
        isError: true,
      );
      return;
    }

    if (widget.elderId.trim().isEmpty) {
      _showMessage(
        'Elder account could not be identified.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? uploadedFilePath;

    try {
      final Uint8List bytes = _selectedBytes!;

      final String contentType =
          _getContentType(
        _selectedFileExtension,
      );

      final String fileName =
          _selectedFileName ?? 'document';

      // Upload file to Supabase Storage.
      uploadedFilePath =
          await SupabaseService.uploadHospitalDocument(
        elderId: widget.elderId,
        fileName: fileName,
        bytes: bytes,
        contentType: contentType,
      );

      // Save document metadata to Firestore.
      await _firestore
          .collection('elders')
          .doc(widget.elderId)
          .collection('hospitalDocuments')
          .add({
        'title': title,
        'description': description,
        'type': _selectedType,
        'filePath': uploadedFilePath,
        'fileName': fileName,
        'fileExtension': _selectedFileExtension,
        'contentType': contentType,
        'fileSize': bytes.length,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _titleController.clear();
      _descriptionController.clear();

      setState(() {
        _selectedBytes = null;
        _selectedFileName = null;
        _selectedFileExtension = null;
        _selectedType = 'Hospital Report';
      });

      _showMessage(
        'Hospital document uploaded successfully.',
      );
    } on FirebaseException catch (e) {
      if (uploadedFilePath != null) {
        try {
          await SupabaseService.deleteHospitalDocument(
            uploadedFilePath,
          );
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        'Database upload failed:\n'
        '${e.message ?? e.code}',
        isError: true,
      );
    } catch (e) {
      if (uploadedFilePath != null) {
        try {
          await SupabaseService.deleteHospitalDocument(
            uploadedFilePath,
          );
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        'Upload failed:\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ============================================================
  // CONTENT TYPE
  // ============================================================

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';

      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      default:
        return 'application/octet-stream';
    }
  }

  // ============================================================
  // DELETE DOCUMENT
  // ============================================================

  Future<void> _deleteDocument(
    String documentId,
    String? filePath,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Document',
          ),
          content: const Text(
            'Are you sure you want to delete this hospital document?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      // Delete Supabase file.
      if (filePath != null &&
          filePath.trim().isNotEmpty) {
        try {
          await SupabaseService
              .deleteHospitalDocument(
            filePath,
          );
        } catch (e) {
          debugPrint(
            'Supabase file deletion failed: $e',
          );
        }
      }

      // Delete Firestore metadata.
      await _firestore
          .collection('elders')
          .doc(widget.elderId)
          .collection('hospitalDocuments')
          .doc(documentId)
          .delete();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Document deleted.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not delete document:\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // OPEN DOCUMENT
  // ============================================================

  Future<void> _openDocument(
    String? filePath,
  ) async {
    if (filePath == null ||
        filePath.trim().isEmpty) {
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

      final bool launched =
          await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) {
          return;
        }

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

  // ============================================================
  // MESSAGE
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF9F1),

      appBar: AppBar(
        title: const Text(
          'Hospital Documents',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor:
            const Color(0xFFFFF9F1),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFE5F4EC),
                borderRadius:
                    BorderRadius.circular(22),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.folder_shared_rounded,
                    size: 42,
                    color:
                        Color(0xFF21866A),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hospital Documents',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                Color(0xFF173B36),
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Upload medical reports, prescriptions and hospital documents for the elder.',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Color(0xFF60736E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // TITLE
            // ======================================================

            const Text(
              'Document title',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  _titleController,
              decoration:
                  InputDecoration(
                hintText:
                    'Example: Blood Test Report',
                prefixIcon:
                    const Icon(
                  Icons.title_rounded,
                ),
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // TYPE
            // ======================================================

            const Text(
              'Document type',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue:
                  _selectedType,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor:
                    Colors.white,
                prefixIcon:
                    const Icon(
                  Icons.category_rounded,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: const [
                'Hospital Report',
                'Prescription',
                'Scan Report',
                'Blood Test',
                'Discharge Summary',
                'Medical Certificate',
                'Other',
              ].map(
                (String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                },
              ).toList(),

              onChanged:
                  (String? value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedType = value;
                });
              },
            ),

            const SizedBox(height: 18),

            // ======================================================
            // DESCRIPTION
            // ======================================================

            const Text(
              'Description',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  _descriptionController,
              maxLines: 3,
              decoration:
                  InputDecoration(
                hintText:
                    'Optional notes about this document',

                prefixIcon:
                    const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 45,
                  ),
                  child: Icon(
                    Icons.notes_rounded,
                  ),
                ),

                filled: true,
                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // FILE PICKER
            // ======================================================

            const Text(
              'Document file',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap:
                  _isUploading
                      ? null
                      : _pickFile,

              child: Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(20),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(18),

                  border:
                      Border.all(
                    color:
                        const Color(0xFF39A982),
                    width: 1.5,
                  ),
                ),

                child: Column(
                  children: [
                    Icon(
                      _selectedBytes == null
                          ? Icons.cloud_upload_rounded
                          : Icons.check_circle_rounded,

                      size: 48,

                      color:
                          _selectedBytes == null
                              ? const Color(0xFF39A982)
                              : Colors.green,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _selectedFileName ??
                          'Tap to select PDF or image',

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'PDF, JPG, JPEG or PNG • Maximum 900 KB',

                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color:
                            Color(0xFF60736E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // UPLOAD BUTTON
            // ======================================================

            SizedBox(
              width: double.infinity,
              height: 56,

              child:
                  ElevatedButton.icon(
                onPressed:
                    _isUploading
                        ? null
                        : _uploadDocument,

                icon:
                    _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.upload_file_rounded,
                          ),

                label: Text(
                  _isUploading
                      ? 'Uploading...'
                      : 'UPLOAD DOCUMENT',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF21866A),

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ======================================================
            // EXISTING DOCUMENTS
            // ======================================================

            const Text(
              'Uploaded documents',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xFF173B36),
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream:
                  _firestore
                      .collection('elders')
                      .doc(widget.elderId)
                      .collection(
                          'hospitalDocuments')
                      .orderBy(
                        'createdAt',
                        descending: true,
                      )
                      .snapshots(),

              builder:
                  (
                BuildContext context,
                AsyncSnapshot<
                        QuerySnapshot<
                            Map<String, dynamic>>>
                    snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Unable to load documents:\n'
                    '${snapshot.error}',
                    style:
                        const TextStyle(
                      color: Colors.red,
                    ),
                  );
                }

                final List<
                        QueryDocumentSnapshot<
                            Map<String, dynamic>>>
                    documents =
                    snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 30,
                    ),
                    child: Center(
                      child: Text(
                        'No documents uploaded yet.',
                        style:
                            TextStyle(
                          color:
                              Color(0xFF60736E),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      documents.map(
                    (
                      QueryDocumentSnapshot<
                              Map<String, dynamic>>
                          document,
                    ) {
                      final Map<String, dynamic>
                          data =
                          document.data();

                      return _DocumentTile(
                        title:
                            data['title']
                                    ?.toString() ??
                                'Hospital Document',

                        type:
                            data['type']
                                    ?.toString() ??
                                'Medical Document',

                        fileName:
                            data['fileName']
                                    ?.toString() ??
                                'File',

                        onOpen: () =>
                            _openDocument(
                          data['filePath']
                              ?.toString(),
                        ),

                        onDelete: () =>
                            _deleteDocument(
                          document.id,
                          data['filePath']
                              ?.toString(),
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// DOCUMENT TILE
// ======================================================================

class _DocumentTile
    extends StatelessWidget {
  final String title;
  final String type;
  final String fileName;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DocumentTile({
    required this.title,
    required this.type,
    required this.fileName,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPdf =
        fileName.toLowerCase().endsWith('.pdf');

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 0,

      color:
          Colors.white,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(17),
      ),

      child: ListTile(
        onTap: onOpen,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: Container(
          height: 48,
          width: 48,

          decoration:
              BoxDecoration(
            color: isPdf
                ? const Color(0xFFFFE1E1)
                : const Color(0xFFE1F4EA),

            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.image_rounded,

            color: isPdf
                ? Colors.red
                : const Color(0xFF21866A),
          ),
        ),

        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        subtitle: Text(
          '$type\n$fileName',
        ),

        isThreeLine: true,

        trailing:
            IconButton(
          onPressed:
              onDelete,

          icon:
              const Icon(
            Icons.delete_outline_rounded,
            color:
                Colors.red,
          ),
        ),
      ),
    );
  }
}