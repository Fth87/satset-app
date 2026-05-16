import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_controller.dart';
import '../../core/ai_parsing_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class ReceiptResultScreen extends StatefulWidget {
  const ReceiptResultScreen({
    super.key,
    required this.controller,
    required this.receipt,
  });

  final AppController controller;
  final ParsedReceipt receipt;

  @override
  State<ReceiptResultScreen> createState() => _ReceiptResultScreenState();
}

class _ReceiptResultScreenState extends State<ReceiptResultScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.receipt.name);
    _phoneController = TextEditingController(text: widget.receipt.phone);
    _addressController = TextEditingController(text: widget.receipt.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) return;
    
    // Add WhatsApp greeting requested by user
    final missing = widget.receipt.missingFields.join(', ');
    final message = "Halo ${_nameController.text},\n\nSalam dari tim kurir logistik. Saya ingin mengkonfirmasi alamat pengiriman Anda, karena data alamat kurang lengkap untuk bagian: $missing.\n\nMohon bantuannya untuk melengkapi alamat agar paket bisa segera dikirim. Terima kasih!";
    
    final uri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _saveData() {
    // Save to AppController state
    // Create a new package or update an existing one
    // Here we'll just add it to the manifest or state
    widget.controller.addPackageFromScan(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    widget.controller.go(AppScreen.manifest);
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.receipt.isAddressComplete;

    return ScrollPage(
      header: AppHeader(
        title: isComplete ? 'Scan Result' : 'Clarification Needed',
        backTo: AppScreen.scanner,
        controller: widget.controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isComplete)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incomplete Address',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The scanned address is missing: ${widget.receipt.missingFields.join(", ")}.',
                    style: const TextStyle(color: Colors.red, height: 1.4),
                  ),
                ],
              ),
            ),
          const Text('Name', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Recipient Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Phone', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Address', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Full Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          if (!isComplete) ...[
            PrimaryButton(
              label: 'Contact via WhatsApp',
              icon: Icons.chat,
              onPressed: _openWhatsApp,
              color: Colors.green, // WhatsApp color
            ),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            label: 'Save & Add to Manifest',
            onPressed: _saveData,
          ),
        ],
      ),
    );
  }
}
