import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'env.dart';

class ParsedReceipt {
  final String name;
  final String phone;
  final String address;
  final bool isAddressComplete;
  final List<String> missingFields;

  ParsedReceipt({
    required this.name,
    required this.phone,
    required this.address,
    required this.isAddressComplete,
    required this.missingFields,
  });

  factory ParsedReceipt.fromJson(Map<String, dynamic> json) {
    return ParsedReceipt(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isAddressComplete: json['isAddressComplete'] ?? false,
      missingFields: List<String>.from(json['missingFields'] ?? []),
    );
  }
}

class AiParsingService {
  static Future<ParsedReceipt?> parseOcrText(String text) async {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint('Gemini API Key is not set.');
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'name': Schema.string(description: 'The name of the recipient'),
            'phone': Schema.string(description: 'The phone number of the recipient'),
            'address': Schema.string(description: 'The full address of the recipient'),
            'isAddressComplete': Schema.boolean(description: 'Whether the address contains enough detail (street, number, city, etc.) for a delivery'),
            'missingFields': Schema.array(items: Schema.string(), description: 'List of fields that are missing or ambiguous (e.g. "house number", "street name", "city")'),
          },
          requiredProperties: ['name', 'phone', 'address', 'isAddressComplete', 'missingFields'],
        ),
      ),
    );

    final prompt = '''
    Extract the recipient's name, phone number, and address from the following OCR text scanned from a shipping label.
    Evaluate if the address is complete enough for a delivery driver to find the location without ambiguity. If it is incomplete or ambiguous, set isAddressComplete to false and list the missing elements in missingFields.
    If any piece of information is completely missing from the text, leave the string empty.
    
    OCR Text:
    """
    $text
    """
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.text!);
        return ParsedReceipt.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('Error parsing with Gemini: $e');
    }
    return null;
  }
}
