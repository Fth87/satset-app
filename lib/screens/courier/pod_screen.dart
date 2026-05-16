
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_controller.dart';
import '../../core/supabase_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class PodScreen extends StatefulWidget {
  const PodScreen({super.key, required this.controller, required this.onToast});

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  State<PodScreen> createState() => _PodScreenState();
}

class _PodScreenState extends State<PodScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isUploading = false;
  String _finalState = 'delivered'; // Using our enum strings

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _finalizeEntry() async {
    if (_imagePath == null) {
      widget.onToast('Please capture a photo first', isError: true);
      return;
    }

    final pkg = widget.controller.selectedPackage;
    if (pkg == null) {
      widget.onToast('No active package selected', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final url = await SupabaseService.uploadPodImage(pkg.id, _imagePath!);
      if (url == null) {
        if (!mounted) return;
        widget.onToast('Failed to upload Proof of Delivery', isError: true);
        setState(() => _isUploading = false);
        return;
      }

      await SupabaseService.updatePackageStatus(pkg.id, _finalState);
      
      // Update local state
      final pkgIndex = widget.controller.packages.indexWhere((p) => p.id == pkg.id);
      if (pkgIndex >= 0) {
        widget.controller.packages.removeAt(pkgIndex); // remove from pending
      }
      
      if (!mounted) return;
      widget.onToast('Transaction committed & Uploaded');
      widget.controller.go(AppScreen.dashboard);
    } catch (e) {
      if (!mounted) return;
      widget.onToast('Error: $e', isError: true);
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Handover Protocol',
        backTo: AppScreen.deliveryDetail,
        controller: widget.controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Final State'),
          DropdownButtonFormField<String>(
            initialValue: _finalState,
            items: const [
              DropdownMenuItem(
                value: 'delivered',
                child: Text('Success - Direct Handover'),
              ),
              DropdownMenuItem(
                value: 'pending',
                child: Text('Abort - Location Empty'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _finalState = value);
              }
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _captureImage,
            child: _imagePath == null
                ? const EvidenceBox(
                    label: 'Capture Media',
                    icon: Icons.camera_alt_outlined,
                    height: 190,
                  )
                : Container(
                    height: 190,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(File(_imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          const EvidenceBox(
            label: 'Draw Input',
            icon: Icons.draw_outlined,
            height: 130,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Finalize Entry',
            isLoading: _isUploading,
            onPressed: _finalizeEntry,
          ),
        ],
      ),
    );
  }
}
