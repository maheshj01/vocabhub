import 'package:flutter/material.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';

class CollectionsNotifier extends ChangeNotifier with ServiceBase {
  // late CollectionsService _collectionService;
  Map<String, List<Word>> _collections = {};
  Map<String, List<Word>> get collections => _collections;

  Future<void> initCollections() async {
    // _collections = await _collectionService.getCollections();
    notifyListeners();
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (!words.containsWord(word)) {
        words.add(word);
        _collections[collectionName] = words;
        showToast('Word added to $collectionName');
      } else {
        showToast('Word already exists in the collection');
      }
    } else {
      collections[collectionName] = [word];
      showToast('Word added to $collectionName');
    }
    // await _collectionService.addToCollection(collectionName, word);
    notifyListeners();
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    // await _collectionService.removeFromCollection(collectionName, word);
    if (collections.containsKey(collectionName)) {
      final List<Word> words = collections[collectionName]!;
      if (words.containsWord(word)) {
        words.remove(word);
        _collections[collectionName] = words;
        showToast('Word removed from $collectionName');
      } else {
        showToast('Word not found in the collection');
      }
    } else {
      showToast('collection not found');
    }
    notifyListeners();
  }

  Future<void> addCollection(String collectionName) async {
    // await _collectionService.addCollection(collectionName);
    if (collections.containsKey(collectionName)) {
      showToast('Collection already exists');
    } else {
      collections[collectionName] = [];
      showToast('Collection added');
    }
    notifyListeners();
  }

  Future<void> setCollections(Map<String, List<Word>> coll) async {
    // await _collectionService.setCollections(collections);
    _collections = coll;
    notifyListeners();
  }

  @override
  Future<void> disposeService() async {}

  @override
  Future<void> initService() async {
    // _collectionService = CollectionsService();
    // await _collectionService.initService();
    await initCollections();
  }
}
