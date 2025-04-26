import 'dart:math';
import 'dart:typed_data';

import 'package:chat_app_diplom/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class EncryptionService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _preferences;
  EncryptionService(this._firestore, this._preferences);// Инициализируем Encrypter
  
  Future<String> encryptMessage(String text, String chatId, String uid, String contactUID) async {
    final secretKey = _preferences.getString("commonKey_$contactUID");
    final doc = await _firestore
      .collection(Constants.keyReceived)
      .doc(chatId)
      .get();
    
    final snapshot = doc.data();

    final p = BigInt.parse(snapshot!["p"]);
    final g = BigInt.parse(snapshot!["g"]);
    final A = BigInt.parse(snapshot!["publicKey"]);
    
    final b = _preferences.getString("privateKey_$uid");

    final B = g.modPow(BigInt.parse(b!), p); // Публичный ключ A
    final sharedSecret = A.modPow(BigInt.parse(b), p);
    final f = Key.fromUtf8(secretKey!);
    final tr = BigInt.parse(secretKey!);
    final _encrypter = Encrypter(AES(Key.fromUtf8(secretKey.substring(0, 32)!)));
    final iv = IV.fromSecureRandom(16); // Новый IV при каждом шифровании
    return "${iv.base64}|${_encrypter.encrypt(text, iv: iv).base64}";
  }
  
  String decryptMessage(String encryptedData,  String contactUID) {
    final secretKey = _preferences.getString("commonKey_$contactUID");
    final _encrypter = Encrypter(AES(Key.fromUtf8(secretKey!.substring(0, 32)!)));
    final parts = encryptedData.split("|");
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  BigInt _generateRandomBigInt(int bitLength) {
    final fullBytes = bitLength ~/ 8;
    final remainingBits = bitLength % 8;
    
    final random = Random.secure();
    final bytes = Uint8List(fullBytes + (remainingBits > 0 ? 1 : 0));
    
    // Fill all bytes with random values
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    
    // Mask the first byte to get the correct number of remaining bits
    if (remainingBits > 0) {
      bytes[0] &= (1 << remainingBits) - 1;
      bytes[0] |= 1 << (remainingBits - 1); // Ensure high bit is set for correct length
    } else {
      bytes[0] |= 0x80; // Ensure high bit is set for correct length
    }
    
    // Convert to BigInt
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }

  // Генерация ключей DH
  Future<Map<String, String>?> generateDHKeys(String userId) async {

    final p = _generateRandomBigInt(256);
    final g = BigInt.from(Random().nextInt(1 << 32));
    final a = BigInt.from(Random().nextInt(1 << 32)); // Приватный ключ A
    final A = g.modPow(a, p); // Публичный ключ A
    // Приватный ключ сохраняем локально
    
    await _preferences.setString("privateKey_$userId", a.toString());
    return {
      "p": p.toString(),
      "g": g.toString(),
      "publicKey": A.toString(),
    };
  }

  Future<String?> getChatId(String contactUID, String senderUID) async {
    final contact = await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(senderUID)
          .get();

    final map = contact.data();
    return map?['chatId'];
  }

  Future<void> createCommomKeyForSender(String contactUID, String userID) async {
    const uuid = Uuid();
    final chatId = uuid.v4();
    final batch = _firestore.batch();

    _preferences.setString("chatId_$contactUID", chatId);
    final a = _preferences.getString("chatId_$contactUID");
    final sender = await _firestore
          .collection(Constants.users)
          .doc(userID)
          .collection(Constants.chats)
          .doc(contactUID);
    
    batch.set(sender, {"chatId": chatId});

    final contact = await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(userID);

    batch.set(contact, {"chatId": chatId});

    

    final doc = await _firestore
      .collection(Constants.users)
      .doc(contactUID)
      .get();
    
    final snapshot = doc.data();

    final p = BigInt.parse(snapshot!["p"]);
    final g = BigInt.parse(snapshot!["g"]);
    final A = BigInt.parse(snapshot!["publicKey"]);
    
    final b = _preferences.getString("privateKey_$userID");

    final B = g.modPow(BigInt.parse(b!), p); // Публичный ключ A

    final key = await _firestore
      .collection(Constants.keyReceived)
      .doc(chatId);

      batch.set(key, {
        "contactID":contactUID,
        "publicKey":B.toString(),
        'chatId':chatId,
        "senderID":userID,
        'p':p.toString(),
        'g':g.toString()
      });

    final sharedSecret = A.modPow(BigInt.parse(b), p);
    _preferences.setString("commonKey_$contactUID", sharedSecret.toString());
    await batch.commit();
    print("Устройство A: Общий секрет = $sharedSecret");
  }

  Future<void> createCommomKeyForContact(String contactUID, String chatId, String? uid) async {
    final keyReceived = await _firestore
      .collection(Constants.keyReceived)
      .doc(chatId)
      .get();
    
    _preferences.setString("chatId_$contactUID", chatId);

    final snapshot = keyReceived.data();
    final snapshotKeyReceived = keyReceived.data();

    final p = BigInt.parse(snapshot!["p"]);
    final g = BigInt.parse(snapshot!["g"]);

    final B = BigInt.parse(snapshotKeyReceived!['publicKey']);

    final a = _preferences.getString("privateKey_$uid");

    final sharedSecret = B.modPow(BigInt.parse(a!), p);
    _preferences.setString("commonKey_$contactUID", sharedSecret.toString());

    print("Устройство B: Общий секрет = $sharedSecret");
  }

  
  


}