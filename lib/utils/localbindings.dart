import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class LocalStorageBindings {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> writeValue({required String key, dynamic value}) {
    return storage.write(key: key, value: value);
  }

  void deleteValue(String key) async {
    storage.delete(key: key);
  }

  Future<dynamic> readValue(String key) async {
    String? value = await storage.read(key: key);
    return value;
  }

  void deleteAll() async {
    storage.deleteAll();
  }

  Future readAll() async {
    Map<String, String> value = await storage.readAll();
    return value;
  }
}

class LocalStorage {
  //singleton instance
  static LocalStorage sharedInstance = LocalStorage._internal();

  factory LocalStorage() {
    return sharedInstance;
  }

  Future<String?> loadUserRef(String key) async {
    return await localStorageBindings.readValue(key);
  }

  Future<dynamic> setUserRef({required String key, dynamic value}) async {
    localStorageBindings.writeValue(key: key, value: value);
  }

  Future<String?> loadAuthStatus(String key) async {
    return await localStorageBindings.readValue(key);
  }

  Future<dynamic> setAuthStatus({required String key, dynamic value}) async {
    localStorageBindings.writeValue(key: key, value: value);
  }

  LocalStorageBindings localStorageBindings = LocalStorageBindings();

  LocalStorage._internal();

  void writeValue({required String key, dynamic value}) {
    localStorageBindings.writeValue(key: key, value: value);
  }

  void deleteValue(String key) async {
    localStorageBindings.deleteValue(key);
  }

  Future<dynamic> readValue(String key) async {
    return await localStorageBindings.readValue(key);
  }

  void deleteAll() async {
    localStorageBindings.deleteAll();
  }

  Future readAll() async {
    return await localStorageBindings.readAll();
  }
}
