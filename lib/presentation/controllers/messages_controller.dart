import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jewelx/domain/models/message.dart';
import 'package:jewelx/domain/models/message_thread.dart';

class MessagesController extends ChangeNotifier {
  MessagesController();

  static const _prefThreads = 'messages.threads';

  final List<MessageThread> _threads = [];

  List<MessageThread> get threads => List.unmodifiable(_threads);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefThreads);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    _threads
      ..clear()
      ..addAll(
        data
            .map((e) => MessageThread.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    notifyListeners();
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _threads.map((thread) => thread.toJson()).toList();
    await prefs.setString(_prefThreads, jsonEncode(data));
  }

  MessageThread openThread(String itemId, String itemName) {
    final index = _threads.indexWhere((thread) => thread.itemId == itemId);
    if (index != -1) {
      return _threads[index];
    }
    final thread = MessageThread(
      itemId: itemId,
      itemName: itemName,
      messages: [
        Message(
          sender: 'seller@jewelx.app',
          content: 'أهلاً! كيف يمكنني مساعدتك في $itemName؟',
          timestamp: DateTime.now(),
          isBuyer: false,
        ),
      ],
    );
    _threads.add(thread);
    notifyListeners();
    unawaited(persist());
    return thread;
  }

  Future<void> sendMessage(String itemId, String text) async {
    final index = _threads.indexWhere((thread) => thread.itemId == itemId);
    if (index == -1) {
      return;
    }
    final thread = _threads[index];
    final updatedMessages = List<Message>.from(thread.messages)
      ..add(
        Message(
          sender: 'me@jewelx.app',
          content: text,
          timestamp: DateTime.now(),
          isBuyer: true,
        ),
      );
    _threads[index] = thread.copyWith(messages: updatedMessages);
    notifyListeners();
    await persist();
  }
}
