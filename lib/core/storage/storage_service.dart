/// Persistent storage service using SharedPreferences.
/// Handles player data save/load with versioned migration.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player_data.dart';

class StorageService {
  static const String _playerDataKey = 'player_data';
  static const String _backupCorruptKey = 'player_data_corrupt_backup';
  static const int _currentVersion = 1;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<PlayerData> loadPlayerData() async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonStr = _prefs!.getString(_playerDataKey);
    if (jsonStr == null) {
      final newData = PlayerData();
      await savePlayerData(newData);
      return newData;
    }
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final data = PlayerData.fromJson(json);
      // Run migrations if needed
      if (data.dataVersion < _currentVersion) {
        data.dataVersion = _currentVersion;
        await savePlayerData(data);
      }
      return data;
    } catch (e) {
      // Corrupted data: preserve original raw string in backup key for forensic recovery
      await _prefs!.setString(_backupCorruptKey, jsonStr);
      final newData = PlayerData();
      await savePlayerData(newData);
      return newData;
    }
  }

  Future<void> savePlayerData(PlayerData data) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(data.toJson());
    await _prefs!.setString(_playerDataKey, jsonStr);
  }

  Future<void> resetAllData() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_playerDataKey);
  }
}
