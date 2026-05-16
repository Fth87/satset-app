import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_controller.dart';
import '../../core/ocr_service.dart';
import '../../core/ai_parsing_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

enum _ScannerStage { camera, preview }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  State<ScannerScreen> createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _controller;
  String? _error;
  bool _isCapturing = false;
  bool _flashOn = false;
  String? _selectedImagePath;
  _ScannerStage _stage = _ScannerStage.camera;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _error = 'No camera available on this device.');
        return;
      }

      final backCamera = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      final selectedCamera = backCamera.isNotEmpty
          ? backCamera.first
          : cameras.first;
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = switch (e.code) {
          'CameraAccessDenied' => 'Camera permission was denied.',
          'CameraAccessDeniedWithoutPrompt' =>
            'Camera permission was denied permanently.',
          _ => 'Unable to open camera.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to open camera.');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureReceipt() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _selectedImagePath = file.path;
        _stage = _ScannerStage.preview;
      });
      widget.onToast('Receipt captured');
    } on CameraException {
      if (!mounted) return;
      widget.onToast('Failed to capture receipt', isError: true);
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image == null || !mounted) return;
      setState(() {
        _selectedImagePath = image.path;
        _stage = _ScannerStage.preview;
      });
    } catch (_) {
      if (!mounted) return;
      widget.onToast('Unable to open gallery', isError: true);
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      _flashOn = !_flashOn;
      await controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      widget.onToast('Flash not supported', isError: true);
    }
  }

  void _retake() {
    if (!mounted) return;
    setState(() {
      _selectedImagePath = null;
      _stage = _ScannerStage.camera;
    });
  }

  bool _isProcessing = false;

  Future<void> _sendToOcr() async {
    if (_selectedImagePath == null || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    widget.onToast('Extracting text from image...');
    
    final text = await OcrService.extractTextFromPath(_selectedImagePath!);
    
    if (text == null || text.isEmpty) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      widget.onToast('Could not extract text. Please try again.', isError: true);
      return;
    }

    widget.onToast('Parsing data with AI...');
    final receipt = await AiParsingService.parseOcrText(text);
    
    if (!mounted) return;
    setState(() => _isProcessing = false);
    
    if (receipt == null) {
      widget.onToast('Failed to parse data. Try again.', isError: true);
      return;
    }

    widget.controller.currentReceipt = receipt;
    widget.controller.go(AppScreen.receiptResult);
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = _controller != null && _controller!.value.isInitialized;

    return ColoredBox(
      color: ink,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _stage == _ScannerStage.preview
                        ? _retake
                        : () => widget.controller.go(AppScreen.dashboard),
                    icon: Icon(
                      _stage == _ScannerStage.preview
                          ? Icons.arrow_back
                          : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'DATA EXTRACTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _stage == _ScannerStage.preview
                    ? PreviewPanel(
                        imagePath: _selectedImagePath!,
                        onRetake: _retake,
                        onSend: _sendToOcr,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_error != null)
                            Container(
                              color: const Color(0xFF111111),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else if (hasPreview)
                            CameraPreview(_controller!)
                          else
                            const ColoredBox(
                              color: Color(0xFF111111),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: _stage == _ScannerStage.preview
                  ? PrimaryButton(
                      label: 'Send OCR Data',
                      icon: Icons.arrow_forward,
                      onPressed: _sendToOcr,
                      isLoading: _isProcessing,
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: IconButton(
                            onPressed: _toggleFlash,
                            icon: Icon(
                              _flashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: _captureReceipt,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: IconButton(
                            onPressed: _pickFromGallery,
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
