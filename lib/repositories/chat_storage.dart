// services/chat_storage.dart
import 'package:hive/hive.dart';

class ChatStorage {
  static late Box<String> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>('chat_messages');
  }

  static Box<String> get box => _box;

  // Методы для работы с сообщениями
  void addMessage(String key, String message) {
    _box.put(key, message);
  }

  String? getMessage(String key) {
    return _box.get(key);
  }

  Map<String, String> getAllMessages() {
    return _box.toMap().cast<String, String>();
  }
}