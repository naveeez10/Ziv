import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:persona/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptApi(String prompt) async {
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $API_SECRET_KEY'
          },
          body: jsonEncode({
            'model': "gpt-3.5-turbo",
            'messages': [
              {
                'role': "user",
                'content':
                    'Does this message want to generate an AI Picture, art or something similar? $prompt. Answer with a simple yes or no.'
              }
            ],
          }));
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await DalleApi(prompt);
            return res;
          default:
            final res = await chatGPTApi(prompt);
            return res;
        }
      }
      return 'Internal Error Occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTApi(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $API_SECRET_KEY'
          },
          body: jsonEncode({
            'model': "gpt-3.5-turbo",
            'messages': messages,
          }));
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      } else {
        print(response.body);
        return "An Internal Error Occured";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> DalleApi(String prompt) async {
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $API_SECRET_KEY'
          },
          body: jsonEncode({
            'prompt': prompt,
            'n': 1,
          }));
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        return imageUrl;
      } else {
        print(response.body);
        return 'An Internal Error occurred';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
