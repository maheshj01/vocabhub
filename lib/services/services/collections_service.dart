import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/collection.dart';
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

  Future<List<VHCollection>> getCollections() async {
    _kCollectionKey = '${authController.user.username}_collection';
    final String? collectionString = _sharedPreferences.getString(_kCollectionKey) ?? '[]';
    if (collectionString != null && collectionString.isNotEmpty) {
      final List<dynamic> collection = jsonDecode(collectionString);
      final List<VHCollection> _collections = [];
      collection.forEach((x) {
        _collections.add(VHCollection.fromJson(x));
      });
      return _collections;
    }
    return [];
  }

  Future<void> setCollections(List<VHCollection> collections) async {
    _kCollectionKey = '${authController.user.username}_collection';
    final List<dynamic> collection = [];
    for (var x in collections) {
      collection.add(x.toJson());
    }
    await _sharedPreferences.setString(_kCollectionKey, jsonEncode(collection));
  }

  Future<void> addCollection(String collectionName) async {
    final List<VHCollection> collections = await getCollections();
    final index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      showToast('Collection already exists');
    } else {
      collections[index] = VHCollection.init();
      collections[index].title = collectionName;
      showToast('Collection added');
    }
    await setCollections(collections);
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    final List<VHCollection> collections = await getCollections();
    int index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      final List<Word> words = collections[index].words;
      if (!words.containsWord(word)) {
        collections[index].words.add(word);
        showToast('Word added to $collectionName');
      } else {
        showToast('Word already exists in the collection');
      }
    } else {
      collections[index] = VHCollection.init();
      collections[index].words.add(word);
      showToast('Word added to $collectionName');
    }
    await setCollections(collections);
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    final List<VHCollection> collections = await getCollections();
    int index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      final List<Word> words = collections[index].words;
      if (words.containsWord(word)) {
        collections[index].words.remove(word);
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
