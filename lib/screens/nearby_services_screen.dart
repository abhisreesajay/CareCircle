import 'package:flutter/material.dart';
import '../models/nearby_service_model.dart';
import '../services/nearby_service_service.dart';

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

class _NearbyServicesScreenState
    extends State<NearbyServicesScreen> {
  final NearbyServiceService _service =
      NearbyServiceService();

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                service == null
                    ? 'Add Nearby Service'
                    : 'Edit Nearby Service',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
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
                          Icons.business_outlined,
                          color: darkGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: darkGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
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
                        setDialogState(() {
                          type = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: darkGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: darkGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    final newService = NearbyService(
                      id: service?.id ??
                          DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                      name: nameController.text,
                      type: type,
                      phone: phoneController.text,
                      address: addressController.text,
                      preferred:
                          service?.preferred ?? false,
                    );

                    final navigator =
                        Navigator.of(context);

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

                    if (!mounted) {
                      return;
                    }

                    navigator.pop();
                  },
                  child: Text(
                    service == null ? 'Add' : 'Update',
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Nearby Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () => _showServiceForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<NearbyService>>(
        stream: _service.getServices(widget.elderId),
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
                      size: 55,
                      color: darkGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load nearby services',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 65,
                      color: primaryGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No nearby services added',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _getServiceIcon(service.type),
                          size: 29,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (service.preferred)
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),
                                    child: const Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: darkGreen,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Preferred',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: darkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              service.type,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: darkGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    service.phone,
                                    style:
                                        const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: darkGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    service.address,
                                    style:
                                        const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: darkGreen,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showServiceForm(
                              service: service,
                            );
                          }

                          if (value == 'delete') {
                            await _service.deleteService(
                              widget.elderId,
                              service.id,
                            );
                          }

                          if (value == 'preferred') {
                            await _service.togglePreferred(
                              widget.elderId,
                              service,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
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
                                  size: 20,
                                  color: darkGreen,
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
                                      : Icons.star,
                                  size: 20,
                                  color: darkGreen,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}