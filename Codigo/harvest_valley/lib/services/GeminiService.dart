import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyDvkzPJYK8HuspYFmtMMro0Ko1YInjVDqs";

  final GenerativeModel _model = GenerativeModel(
    model:
        'gemini-2.5-flash-lite', // se quiser usar uma descrição melhor podemos usar model: 'gemini-2.5-pro', mas é mais lento
    apiKey: _apiKey,
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ],
  );

  GeminiService._privateConstructor();
  static final GeminiService _instance = GeminiService._privateConstructor();
  factory GeminiService() {
    return _instance;
  }

  Future<String> generateDialogue(String prompt) async {
    try {
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      if (response.text != null) {
        return response.text!.replaceAll('"', '').trim();
      } else {
        print("Erro na API Gemini: Resposta nula.");
        return "Hmm... esqueci o que ia dizer.";
      }
    } catch (e) {
      print("Exceção ao chamar a API Gemini: $e");

      if (e.toString().contains('API_KEY_INVALID')) {
        return "Minha magia de IA não está funcionando... (Chave inválida)";
      }

      return "ERRO NO CATCH: ${e.toString()}";

      // print("Exceção ao chamar a API Gemini: $e");

      // if (e.toString().contains('API_KEY_INVALID')) {
      //   return "Minha magia de IA não está funcionando... (Chave inválida)";
      // }

      // return "Não estou com vontade de falar agoraabrubu.";
    }
  }

  Future<String?> generateJson(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) return null;

      return text.replaceAll('```json', '').replaceAll('```', '').trim();
    } catch (e) {
      print("Erro Gemini JSON: $e");
      return null;
    }
  }
}
