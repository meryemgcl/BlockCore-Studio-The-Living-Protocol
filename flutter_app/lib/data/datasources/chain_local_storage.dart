import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/block.dart';

class ChainLocalStorage {
  static const _chainKey = 'blockcore.chain.v1';

  Future<void> saveChain(List<Block> blocks) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      blocks.map((block) => block.toJson()).toList(growable: false),
    );
    await preferences.setString(_chainKey, payload);
  }

  Future<List<Block>> loadChain() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = preferences.getString(_chainKey);
    if (payload == null || payload.isEmpty) return [];

    try {
      final decoded = jsonDecode(payload) as List<dynamic>;
      return decoded
          .map((item) => Block.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> clearChain() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_chainKey);
  }
}
