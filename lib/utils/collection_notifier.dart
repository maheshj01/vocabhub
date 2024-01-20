import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/collection.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';

class CollectionStateNotifier extends StateNotifier<AsyncValue<List<VHCollection>>> {
  CollectionStateNotifier(this.sharedPreferences, this.ref) : super(AsyncValue.loading()) {
    init();
  }

  String _kCollectionKey = 'kCollection';

  set collectionKey(String value) {
    _kCollectionKey = value;
  }

  Future<void> init() async {
    state = AsyncValue.loading();
    try {
      final user = ref.read(userNotifierProvider).value!;
      _kCollectionKey = '${user.username}_collection';
      final collections = await getCollections();
      state = AsyncValue.data(collections);
    } catch (e, y) {
      state = AsyncValue.error(e, y);
    }
  }

  Future<List<VHCollection>> getCollections() async {
    state = AsyncValue.loading();
    final String? collectionString = sharedPreferences.getString(_kCollectionKey) ?? '[]';
    if (collectionString != null && collectionString.isNotEmpty) {
      final List<dynamic> collection = jsonDecode(collectionString);
      final List<VHCollection> _collections = [];
      collection.forEach((x) {
        _collections.add(VHCollection.fromJson(x));
      });
      setCollections(_collections);
      return _collections;
    }
    setCollections([]);
    return [];
  }

  Future<void> setCollections(List<VHCollection> collections) async {
    state = AsyncValue.loading();
    final List<dynamic> collection = [];
    for (var x in collections) {
      collection.add(x.toJson());
    }
    await sharedPreferences.setString(_kCollectionKey, jsonEncode(collection));
    state = AsyncValue.data(collections);
  }

  Future<void> deleteCollection(String collectionName) async {
    final List<VHCollection> collections = state.value!;

    int index = collections.indexOfCollection(collectionName);
    if (index != -1) {
      collections.removeAt(index);
      showToast('Collection deleted');
    } else {
      showToast('Collection not found');
    }
    await setCollections(collections);
  }

  Future<void> togglePin(String title) async {
    // await _collectionService.togglePin(title);
    final List<VHCollection> collections = state.value!;

    int index = collections.indexOfCollection(title);
    if (index != -1) {
      collections[index].isPinned = !collections[index].isPinned;
      showToast(
          'Collection ${collections[index].isPinned ? 'pinned to' : 'unpinned from'} Dashboard');
    } else {
      showToast('Collection not found');
    }
    await setCollections(collections);
  }

  Future<void> addCollection(VHCollection collection) async {
    final List<VHCollection> collections = await getCollections();

    int index = collections.indexOfCollection(collection.title);
    if (index != -1) {
      showToast('Collection already exists');
    } else {
      collections.add(collection);
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

  SharedPreferences sharedPreferences;
  Ref ref;
}
