import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'main.dart'; // to get apiProvider

// ─── Dashboard State ────────────────────────────────────────────────────────
final userStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(apiProvider);
  final response = await dio.get('/api/user/state');
  return response.data['data'];
});

// ─── Meal Planner State ─────────────────────────────────────────────────────
final plannerProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(apiProvider);
  final response = await dio.post('/api/planner/generate');
  return response.data['data']['plan'];
});

// ─── Settings Preferences State ─────────────────────────────────────────────
class SettingsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {"diet": "Standard", "notifications": true};
  
  Future<void> updatePreferences(String? diet, bool? notifs) async {
    final dio = ref.read(apiProvider);
    final response = await dio.patch('/api/user/preferences', data: {
      if (diet != null) "diet": diet,
      if (notifs != null) "notifications": notifs,
    });
    state = response.data['data'];
  }
}
final settingsProvider = NotifierProvider<SettingsNotifier, Map<String, dynamic>>(SettingsNotifier.new);

// ─── AI Assistant Chat State ────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? recipe;
  
  ChatMessage(this.text, {required this.isUser, this.recipe});
}

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [
    ChatMessage("Hi Alex! I notice you have a 650 kcal target for dinner. I can recommend some fiber-rich options.", isUser: false)
  ];
  
  Future<void> sendMessage(String text) async {
    // 1. Append User Message
    state = [...state, ChatMessage(text, isUser: true)];
    
    // 2. Add temporary loading indicator bubble (optional, but good UX)
    final loadingMsg = ChatMessage("...", isUser: false);
    state = [...state, loadingMsg];
    
    try {
      final dio = ref.read(apiProvider);
      final response = await dio.post('/api/chat', data: {
        "message": text,
        "context": {"time": "06:30 PM", "recent_workout": false} // Mocked context
      });
      
      final replyText = response.data['text'];
      final recipe = response.data['recipe'];
      
      // Replace loading bubble with actual response
      state = [
        ...state.take(state.length - 1),
        ChatMessage(replyText, isUser: false, recipe: recipe)
      ];
    } catch (e) {
      state = [
        ...state.take(state.length - 1),
        ChatMessage("Error communicating with AI Core: $e", isUser: false)
      ];
    }
  }
}
final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
