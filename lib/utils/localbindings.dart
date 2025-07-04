import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


// class LocalStorageBindings {
//   final storage = const FlutterSecureStorage(
//     aOptions: AndroidOptions(
//       encryptedSharedPreferences: true,
//     ),
//   );
//
//   Future<void> writeValue({required String key, dynamic value}) {
//     return storage.write(key: key, value: value);
//   }
//
//   void deleteValue(String key) async {
//     storage.delete(key: key);
//   }
//
//   Future<dynamic> readValue(String key) async {
//     String? value = await storage.read(key: key);
//     return value;
//   }
//
//   void deleteAll() async {
//     storage.deleteAll();
//   }
//
//   Future readAll() async {
//     Map<String, String> value = await storage.readAll();
//     return value;
//   }
// }

// class LocalStorage {
//   //singleton instance
//   static LocalStorage sharedInstance = LocalStorage._internal();
//
//   factory LocalStorage() {
//     return sharedInstance;
//   }
//
//   Future<String?> loadUserRef(String key) async {
//     return await localStorageBindings.readValue(key);
//   }
//
//   Future<dynamic> setUserRef({required String key, dynamic value}) async {
//     localStorageBindings.writeValue(key: key, value: value);
//   }
//
//   Future<String?> loadAuthStatus(String key) async {
//     return await localStorageBindings.readValue(key);
//   }
//
//   Future<dynamic> setAuthStatus({required String key, dynamic value}) async {
//     localStorageBindings.writeValue(key: key, value: value);
//   }
//
//   LocalStorageBindings localStorageBindings = LocalStorageBindings();
//
//   LocalStorage._internal();
//
//   void writeValue({required String key, dynamic value}) {
//     localStorageBindings.writeValue(key: key, value: value);
//   }
//
//   void deleteValue(String key) async {
//     localStorageBindings.deleteValue(key);
//   }
//
//   Future<dynamic> readValue(String key) async {
//     return await localStorageBindings.readValue(key);
//   }
//
//   void deleteAll() async {
//     localStorageBindings.deleteAll();
//   }
//
//   Future readAll() async {
//     return await localStorageBindings.readAll();
//   }
// }

class LocalStorage {
  // Singleton instance
  static LocalStorage? _instance;
  static LocalStorage get sharedInstance {
    _instance ??= LocalStorage._internal();
    return _instance!;
  }

  LocalStorage._internal();

  // Method to write value (async for web compatibility)
  Future<void> writeValue({required String key, required dynamic value}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String stringValue = value is String ? value : jsonEncode(value);
      await prefs.setString(key, stringValue);
      print('Successfully wrote to key: $key');
    } catch (e) {
      print('Error writing to localStorage: $e');
    }
  }

  // Method to read value
  Future<dynamic> readValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      print('Read from key $key: $value');
      return value;
    } catch (e) {
      print('Error reading from localStorage: $e');
      return null;
    }
  }

  // Method to delete a specific value
  Future<void> deleteValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      print('Deleted key: $key');
    } catch (e) {
      print('Error deleting from localStorage: $e');
    }
  }

  // Method to clear all values
  Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Cleared all localStorage');
    } catch (e) {
      print('Error clearing localStorage: $e');
    }
  }

  // Method to get all keys
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys();
    } catch (e) {
      print('Error getting all keys: $e');
      return <String>{};
    }
  }

  // Convenience methods for specific data types
  Future<void> setString(String key, String value) async {
    await writeValue(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await readValue(key) as String?;
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Legacy method names for compatibility
  Future<String?> loadUserRef(String key) async {
    return await getString(key);
  }

  Future<void> setUserRef({required String key, required dynamic value}) async {
    await writeValue(key: key, value: value);
  }

  Future<String?> loadAuthStatus(String key) async {
    return await getString(key);
  }

  Future<void> setAuthStatus({required String key, required dynamic value}) async {
    await writeValue(key: key, value: value);
  }
}
