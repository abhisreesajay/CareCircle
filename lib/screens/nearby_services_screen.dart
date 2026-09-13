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
              title: Text(
                service == null
                    ? 'Add Nearby Service'
                    : 'Edit Nearby Service',
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Services'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<NearbyService>>(
        stream: _service.getServices(widget.elderId),
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

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Text(
                'No nearby services added',
              ),
            );
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(
                    service.type == 'Hospital'
                        ? Icons.local_hospital
                        : service.type == 'Restaurant'
                            ? Icons.restaurant
                            : service.type == 'Shop'
                                ? Icons.store
                                : Icons.medical_services,
                  ),
                  title: Text(service.name),
                  subtitle: Text(
                    '${service.type}\n'
                    '${service.phone}\n'
                    '${service.address}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
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
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'preferred',
                        child: Text(
                          service.preferred
                              ? 'Remove Preferred'
                              : 'Make Preferred',
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
    );
  }
}