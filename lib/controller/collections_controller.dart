import 'package:flutter/material.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/collections_service.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';

class CollectionsNotifier extends ChangeNotifier with ServiceBase {
  late CollectionsService _collectionService;
  List<VHCollection> _collections = [];
  List<VHCollection> get collections => _collections;

  Future<void> initCollections() async {
    _collections = await _collectionService.getCollections();
    notifyListeners();
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    final index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      final List<Word> words = collections[index].words;
      if (!words.containsWord(word)) {
        _collections[index].words.add(word);
        await _collectionService.setCollections(collections);
        showToast('Word added to $collectionName');
      } else {
        showToast('Word already exists in the collection');
      }
    } else {
      collections[index] = VHCollection.init();
      collections[index].words.add(word);
      showToast('Word added to $collectionName');
    }
    notifyListeners();
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    // await _collectionService.removeFromCollection(collectionName, word);
    final index = _collections.indexOfCollection(collectionName);
    if (index != -1) {
      final List<Word> words = _collections[index].words;
      if (words.containsWord(word)) {
        _collections[index].words.remove(word);
        await _collectionService.setCollections(_collections);
        showToast('Word removed from $collectionName');
      } else {
        showToast('Word not found in the collection');
      }
    } else {
      showToast('collection not found');
    }
    notifyListeners();
  }

  Future<void> addCollection(String collectionName,bool isPinned) async {
    // await _collectionService.addCollection(collectionName);
    int index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      showToast('Collection already exists');
    } else {
      final newCollection = VHCollection.init(
        pinned: isPinned
      );
      newCollection.title = collectionName;
      collections.add(newCollection);
      showToast('Collection added');
    }
    notifyListeners();
  }

  Future<void> deleteCollection(String collectionName) async {
    // await _collectionService.deleteCollection(collectionName);
    int index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      collections.removeAt(index);
      showToast('Collection deleted');
      _collectionService.setCollections(collections);
    } else {
      showToast('Collection not found');
    }
    notifyListeners();
  }

  Future<void> togglePin(String title) async {
    // await _collectionService.togglePin(title);
    int index = collections.indexOfCollection(title);
    if (index != -1) {
      collections[index].isPinned = !collections[index].isPinned;
      showToast(
          'Collection ${collections[index].isPinned ? 'pinned to' : 'unpinned from'} Dashboard');
      _collectionService.setCollections(collections);
    } else {
      showToast('Collection not found');
    }
    notifyListeners();
  }

  @override
  Future<void> disposeService() async {}

  @override
  Future<void> initService() async {
    _collectionService = CollectionsService();
    await _collectionService.initService();
    await initCollections();
  }
}
