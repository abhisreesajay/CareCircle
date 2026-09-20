import 'package:flutter/material.dart';
import '../../models/nearby_service_model.dart';
import '../../services/caregiver/nearby_service_service.dart';

class NearbyServicesScreen extends StatefulWidget {
  final String elderId;

  const NearbyServicesScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<NearbyServicesScreen> createState() =>
      _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  final NearbyServiceService _service = NearbyServiceService();

  // CareCircle palette
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color backgroundColor = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  void _showServiceForm({NearbyService? service}) {
    final nameController =
        TextEditingController(text: service?.name ?? '');

    final phoneController =
        TextEditingController(text: service?.phone ?? '');

    final addressController =
        TextEditingController(text: service?.address ?? '');

    String type = service?.type ?? 'Hospital';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: cream,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: sage.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.location_city_outlined,
                            color: darkSage,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            service == null
                                ? 'Add nearby service'
                                : 'Edit nearby service',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _InputField(
                      controller: nameController,
                      label: 'Service name',
                      hint: 'e.g. City Hospital',
                      icon: Icons.business_outlined,
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: 'Service type',
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: darkSage,
                        ),
                        filled: true,
                        fillColor: backgroundColor,
                        labelStyle: const TextStyle(
                          color: mutedText,
                        ),
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
                            color: sage,
                            width: 1.5,
                          ),
                        ),
                      ),
                      dropdownColor: cream,
                      items: const [
                        DropdownMenuItem(
                          value: 'Hospital',
                          child: Text('Hospital'),
                        ),
                        DropdownMenuItem(
                          value: 'Care Centre',
                          child: Text('Care Centre'),
                        ),
                        DropdownMenuItem(
                          value: 'Shop',
                          child: Text('Shop'),
                        ),
                        DropdownMenuItem(
                          value: 'Restaurant',
                          child: Text('Restaurant'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          type = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _InputField(
                      controller: phoneController,
                      label: 'Phone number',
                      hint: 'Service contact number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    _InputField(
                      controller: addressController,
                      label: 'Address',
                      hint: 'Service location',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: darkSage,
                              side: BorderSide(
                                color: sage.withValues(alpha: 0.45),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.trim().isEmpty) {
                                return;
                              }

                              final newService = NearbyService(
                                id: service?.id ??
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                name: nameController.text.trim(),
                                type: type,
                                phone: phoneController.text.trim(),
                                address: addressController.text.trim(),
                                preferred:
                                    service?.preferred ?? false,
                              );

                              if (service == null) {
                                await _service.addService(
                                  widget.elderId,
                                  newService,
                                );
                              } else {
                                await _service.updateService(
                                  widget.elderId,
                                  newService,
                                );
                              }

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkSage,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              service == null ? 'Add service' : 'Save changes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getServiceIcon(String type) {
    if (type == 'Hospital') {
      return Icons.local_hospital_outlined;
    }

    if (type == 'Restaurant') {
      return Icons.restaurant_outlined;
    }

    if (type == 'Shop') {
      return Icons.store_outlined;
    }

    return Icons.medical_services_outlined;
  }

  Color _getServiceColor(String type) {
    if (type == 'Hospital') {
      return terracotta;
    }

    if (type == 'Restaurant') {
      return sage;
    }

    if (type == 'Shop') {
      return darkSage;
    }

    return sage;
  }

  String _getServiceDescription(String type) {
    if (type == 'Hospital') {
      return 'Medical care';
    }

    if (type == 'Care Centre') {
      return 'Care & support';
    }

    if (type == 'Shop') {
      return 'Nearby shopping';
    }

    return 'Food & dining';
  }

  Future<void> _deleteService(NearbyService service) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Remove service?',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Remove "${service.name}" from nearby services?',
            style: const TextStyle(
              color: mutedText,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkSage,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: terracotta,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _service.deleteService(
      widget.elderId,
      service.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Nearby services',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceForm(),
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<List<NearbyService>>(
        stream: _service.getServices(widget.elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const _EmptyServiceState();
          }

          final preferredCount =
              services.where((service) => service.preferred).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              110,
            ),
            children: [
              _IntroCard(
                serviceCount: services.length,
                preferredCount: preferredCount,
              ),

              const SizedBox(height: 24),

              const Text(
                'Your nearby places',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Important places saved for easy access.',
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                ),
              ),

              const SizedBox(height: 16),

              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ServiceCard(
                    service: service,
                    icon: _getServiceIcon(service.type),
                    accentColor: _getServiceColor(service.type),
                    description:
                        _getServiceDescription(service.type),
                    onEdit: () {
                      _showServiceForm(
                        service: service,
                      );
                    },
                    onDelete: () {
                      _deleteService(service);
                    },
                    onPreferred: () async {
                      await _service.togglePreferred(
                        widget.elderId,
                        service,
                      );
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

class _IntroCard extends StatelessWidget {
  final int serviceCount;
  final int preferredCount;

  const _IntroCard({
    required this.serviceCount,
    required this.preferredCount,
  });

  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkSage,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cream.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.location_city_outlined,
              color: cream,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Care close by',
                  style: TextStyle(
                    color: cream,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$serviceCount saved • $preferredCount preferred',
                  style: TextStyle(
                    color: cream.withValues(alpha: 0.72),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final NearbyService service;
  final IconData icon;
  final Color accentColor;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPreferred;

  const _ServiceCard({
    required this.service,
    required this.icon,
    required this.accentColor,
    required this.description,
    required this.onEdit,
    required this.onDelete,
    required this.onPreferred,
  });

  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);
  static const Color darkSage = Color(0xFF46695A);
  static const Color backgroundColor = Color(0xFFF4EFE5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz,
                            color: darkSage,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            }

                            if (value == 'delete') {
                              onDelete();
                            }

                            if (value == 'preferred') {
                              onPreferred();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: darkSage,
                                    size: 20,
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
                                    color: darkSage,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'preferred',
                              child: Row(
                                children: [
                                  Icon(
                                    service.preferred
                                        ? Icons.star_border
                                        : Icons.star_outline,
                                    color: darkSage,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    service.preferred
                                        ? 'Remove Preferred'
                                        : 'Make Preferred',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service.type,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: darkSage,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                _ContactRow(
                  icon: Icons.phone_outlined,
                  text: service.phone.isEmpty
                      ? 'No phone number added'
                      : service.phone,
                ),
                const SizedBox(height: 10),
                _ContactRow(
                  icon: Icons.location_on_outlined,
                  text: service.address.isEmpty
                      ? 'No address added'
                      : service.address,
                ),
              ],
            ),
          ),

          if (service.preferred) ...[
            const SizedBox(height: 13),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 15,
                        color: accentColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Preferred service',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({
    required this.icon,
    required this.text,
  });

  static const Color darkSage = Color(0xFF46695A);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: darkSage,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: mutedText,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  static const Color backgroundColor = Color(0xFFF4EFE5);
  static const Color darkSage = Color(0xFF46695A);
  static const Color sage = Color(0xFF7FA68F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: darkSage,
        ),
        filled: true,
        fillColor: backgroundColor,
        labelStyle: const TextStyle(
          color: mutedText,
        ),
        hintStyle: const TextStyle(
          color: mutedText,
          fontSize: 13,
        ),
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
            color: sage,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyServiceState extends StatelessWidget {
  const _EmptyServiceState();

  static const Color cream = Color(0xFFFFFBF4);
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: sage.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_outlined,
                  size: 36,
                  color: darkSage,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'No nearby services yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add hospitals, care centres, shops or restaurants that are useful for your elder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Tap “Add service” to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: darkSage.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: terracotta.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 34,
                  color: terracotta,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Unable to load services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}