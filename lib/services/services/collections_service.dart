import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';

class CollectionsService extends ServiceBase {
  late String _kCollectionKey;
  late SharedPreferences _sharedPreferences;

  set collectionKey(String value) {
    _kCollectionKey = value;
  }

  Future<Map<String, List<Word>>> getCollections() async {
    _kCollectionKey = '${authController.user.username}_collection';
    final String? collectionString = _sharedPreferences.getString(_kCollectionKey) ?? '{}';
    if (collectionString != null && collectionString.isNotEmpty) {
      final Map<String, dynamic> collection = jsonDecode(collectionString);
      final Map<String, List<Word>> _collections = {};
      collection.forEach((key, value) {
        _collections[key] = (value as List).map((e) => Word.fromJson(e)).toList();
      });
      return _collections;
    }
    return {};
  }

  Future<void> setCollections(Map<String, List<Word>> collections) async {
    _kCollectionKey = '${authController.user.username}_collection';
    final Map<String, dynamic> collection = {};
    collections.forEach((key, value) {
      collection[key] = value.map((e) => e.toJson()).toList();
    });
    await _sharedPreferences.setString(_kCollectionKey, jsonEncode(collection));
  }

  Future<void> addCollection(String collectionName) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      showToast('Collection already exists');
    } else {
      collections[collectionName] = [];
      showToast('Collection added');
    }
    await setCollections(collections);
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (!words.containsWord(word)) {
        words.add(word);
        showToast('Word added to $collectionName');
      } else {
        showToast('Word already exists in the collection');
      }
    } else {
      collections[collectionName] = [word];
      showToast('Word added to $collectionName');
    }
    await setCollections(collections);
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    final Map<String, List<Word>> collections = await getCollections();
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (words.containsWord(word)) {
        words.remove(word);
        showToast('Word removed from $collectionName');
      } else {
        showToast('Word does not exist in the collection');
      }
    } else {
      showToast('Word does not exist in the collection');
    }
    await setCollections(collections);
  }

  @override
  Future<void> disposeService() async {}

  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _kCollectionKey = 'kCollectionKey';
  }
}
