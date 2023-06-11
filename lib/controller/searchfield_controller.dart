import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/search_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class SearchFieldController extends ChangeNotifier with ServiceBase {
  late TextEditingController _searchController;
  late SearchService _searchService;


  List<Word> _recents = [];

  String get searchText => _searchController.text;

  void setText(String text) {
    _searchController.text = text;
    notifyListeners();
  }

  set searchController(TextEditingController controller) {
    _searchController = controller;
    notifyListeners();
  }

  SearchFieldController({TextEditingController? controller}) {
    _searchController = TextEditingController();
    if (controller != null) {
      _searchController = controller;
    }
    _searchController.addListener(notifyListeners);
    initService();
  }

  TextEditingController get controller => _searchController;

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Word>> recents() async {
    if (_recents.isNotEmpty) {
      return _recents;
    }
    return await _searchService.recents;
  }

  void addRecent(Word word) async {
    _recents.add(word);
    await _searchService.addRecent(word);
    notifyListeners();
  }

  void removeRecent(Word word) async {
    _recents.remove(word);
    await _searchService.removeRecent(word);
    notifyListeners();
  }

  @override
  Future<void> initService() async {
    _searchService = SearchService();
    _searchService.initService();
  }
}
