import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_controller.dart';
import '../../models/package.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key, required this.controller});

  final AppController controller;

  void _onContactPressed(BuildContext context, String? phone, VoidCallback action) {
    if (phone == null || phone.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: const Text('Nomor telepon tidak tersedia untuk paket ini.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      action();
    }
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('whatsapp://send?phone=$phone');
    if (!await launchUrl(url)) {
      final Uri webUrl = Uri.parse('https://wa.me/$phone');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditDialog(BuildContext context, DeliveryPackage pkg) {
    final nameController = TextEditingController(text: pkg.recipient);
    final addressController = TextEditingController(text: pkg.address);
    final phoneController = TextEditingController(text: pkg.phone ?? '');
    final priorityOptions = ['Standard', 'Express', 'Priority'];
    String currentPriority = priorityOptions.contains(pkg.priority) ? pkg.priority : 'Standard';
    PackageStatus currentStatus = pkg.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Package Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Recipient Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: currentPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: priorityOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => currentPriority = val!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PackageStatus>(
                  initialValue: currentStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: PackageStatus.pending, child: Text('Akan Dikirim')),
                    DropdownMenuItem(value: PackageStatus.clarification, child: Text('Anomaly')),
                    DropdownMenuItem(value: PackageStatus.delivered, child: Text('Finished')),
                  ],
                  onChanged: (val) => setDialogState(() => currentStatus = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                controller.updatePackage(pkg.id, {
                  'recipient': nameController.text,
                  'address': addressController.text,
                  'phone': phoneController.text,
                  'priority': currentPriority,
                  'status': currentStatus.name,
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = controller.selectedPackage ?? controller.packages.first;
    return ScrollPage(
      bottomPadding: 92,
      header: AppHeader(
        title: 'Payload Data',
        backTo: AppScreen.manifest,
        controller: controller,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, pkg),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Package'),
                    content: const Text('Are you sure you want to delete this package?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success = await controller.deletePackage(pkg.id);
                  if (!context.mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package deleted')));
                    controller.go(AppScreen.manifest);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal menghapus paket. Pastikan tidak ada data terkait.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pkg.id,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Chip(label: Text('Class: ${pkg.priority}')),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  pkg.recipient,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (pkg.phone != null && pkg.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(pkg.phone!, style: const TextStyle(color: muted)),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pkg.address,
                        style: const TextStyle(color: muted, height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (pkg.status == PackageStatus.clarification) ...[
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'UBAH ALAMAT',
                    icon: Icons.edit_location_alt,
                    onPressed: () => _showEditDialog(context, pkg),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Call',
                        icon: Icons.call,
                        isDisabled: pkg.phone == null || pkg.phone!.isEmpty,
                        onPressed: () => _onContactPressed(context, pkg.phone, () => _makeCall(pkg.phone)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'WhatsApp',
                        icon: Icons.chat,
                        isDisabled: pkg.phone == null || pkg.phone!.isEmpty,
                        onPressed: () => _onContactPressed(context, pkg.phone, () => _openWhatsApp(pkg.phone)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Execute Handover',
            onPressed: () => controller.go(AppScreen.pod),
          ),
        ],
      ),
    );
  }
}
