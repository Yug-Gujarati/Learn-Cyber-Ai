import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/ai_chat_model.dart';

class AIChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  String geminiApiKey = "AIzaSyCJqqPs7sedEz2Bn-cqEEltvbMinD6R8mE";

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Send message to Gemini API
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ]
        }
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]
            ?? "I couldn't process that, please try again.";

        _messages.add(ChatMessage(text: reply, isUser: false));
        print("this is success message ${response.body}");
      } else {
        _messages.add(ChatMessage(
          text: "⚠️ Error: ${response.statusCode}",
          isUser: false,
        ));

        print("this is error message ${response.body}");
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "❌ Error: $e", isUser: false));
    }

    _isLoading = false;
    notifyListeners();
  }
}

