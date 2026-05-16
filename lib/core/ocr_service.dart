import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String?> extractTextFromPath(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
