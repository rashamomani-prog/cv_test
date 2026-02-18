import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = 'AIzaSyDT34xuAXOyWT898-nV3ZSu1OcAXzG11yE';

  static Future<String> getSuggestions(String jobTitle, String type) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.0-pro',
        apiKey: _apiKey,
      );

      String prompt = "";
      if (type == 'summary') {
        prompt = "Write a professional 2-line CV summary for a $jobTitle.";
      } else if (type == 'skills') {
        prompt = "List 5 professional skills for a $jobTitle, separated by commas.";
      } else {
        prompt = "Provide 3 work experience bullet points for a $jobTitle.";
      }

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!.trim();
      } else {
        return "لم يتم العثور على اقتراحات.";
      }
    } catch (e) {
      print("Detailed AI Error: $e");
      return "حدث خطأ: تأكد من اتصال الإنترنت أو تحديث المكتبة.";
    }
  }
}