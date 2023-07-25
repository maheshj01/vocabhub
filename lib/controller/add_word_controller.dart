import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/add_word_service.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/utils.dart';

class AddWordController extends ChangeNotifier with ServiceBase {
  late List<Word> _drafts;
  late AddWordService _addWordService;
  late bool hasDrafts = false;

  List<Word> get drafts => _drafts;

  Future<void> saveDrafts(Word word) async {
    if (word.isWordEmpty()) return;
    _drafts.add(word);
    hasDrafts = true;
    await _addWordService.setWordToDraft(_drafts);
    notifyListeners();
  }

  Future<List<Word>> loadDrafts() async {
    _drafts = _addWordService.getWordFromDraft();
    hasDrafts = _drafts.isNotEmpty;
    return _drafts;
  }

  Future<void> removeDraft(Word word) async {
    _drafts.removeWhere((element) => element.equals(word));
    await _addWordService.setWordToDraft(_drafts);
    notifyListeners();
  }

  @override
  Future<void> disposeService() {
    throw UnimplementedError();
  }

  @override
  Future<void> initService() async {
    _drafts = [];
    _addWordService = AddWordService();
    await _addWordService.initService();
    await loadDrafts();
  }
}
