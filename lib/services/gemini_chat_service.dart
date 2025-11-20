import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiChatService {
  final String modelName;
  String? systemPrompt;
  double temperature = 0.2;
  final GenerativeModel? _model;
  final bool enabled;
  final String? initError;

  GeminiChatService._(this.modelName, this._model)
    : enabled = true,
      initError = null;

  factory GeminiChatService({String modelName = 'gemini-1.5-flash'}) {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return GeminiChatService._disabled('Missing GEMINI_API_KEY in .env');
      }
      final envModel = dotenv.env['GEMINI_MODEL'] ?? modelName;
      final system = dotenv.env['GEMINI_SYSTEM_PROMPT'];
      final tempStr = dotenv.env['GEMINI_TEMPERATURE'];
      double temp = 0.2;
      if (tempStr != null) {
        temp = double.tryParse(tempStr) ?? temp;
      }
      final model = GenerativeModel(model: envModel, apiKey: apiKey);
      return GeminiChatService._(envModel, model).._setOptions(system, temp);
    } catch (e, st) {
      debugPrint('GeminiChatService init error: $e\n$st');
      return GeminiChatService._disabled(e.toString());
    }
  }

  GeminiChatService._disabled(this.initError)
    : enabled = false,
      modelName = 'disabled',
      _model = null;

  void _setOptions(String? system, double temp) {
    systemPrompt = system;
    temperature = temp;
  }

  Future<String> ask(String prompt, {List<Content>? history}) async {
    try {
      if (!enabled) {
        debugPrint(
          'GeminiChatService.ask called but service disabled: $initError',
        );
        return 'Chatbot not configured: ${initError ?? 'missing API key'}';
      }
      // Compose prompt with optional system prompt to guide the assistant.
      final sys = dotenv.env['GEMINI_SYSTEM_PROMPT'];
      final fullPrompt = (sys != null && sys.isNotEmpty)
          ? '$sys\n\nUser: $prompt'
          : prompt;
      debugPrint('Gemini prompt: $fullPrompt');
      final chat = _model!.startChat(history: history ?? const []);
      final response = await chat.sendMessage(Content.text(fullPrompt));
      debugPrint('Gemini response: ${response.text}');
      return response.text?.trim() ?? '';
    } catch (e, st) {
      debugPrint('Gemini error: $e\n$st');
      rethrow;
    }
  }
}
