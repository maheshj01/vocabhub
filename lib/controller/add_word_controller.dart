import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/add_word_service.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/utils.dart';

class AddWordController extends ChangeNotifier with ServiceBase {
  late Word _drafts;
  late AddWordService _addWordService;
  late bool hasDrafts = false;

  Word get drafts => _drafts;

  Future<void> saveDrafts(Word word) async {
    _drafts = word;
    hasDrafts = true;
    await _addWordService.setWordToDraft(word);
    notifyListeners();
  }

  Future<void> loadDrafts() async {
    _drafts = _addWordService.getWordFromDraft();
    hasDrafts = !_drafts.isWordEmpty();
  }

  @override
  Future<void> disposeService() {
    throw UnimplementedError();
  }

  @override
  Future<void> initService() async {
    _drafts = Word.init();
    _addWordService = AddWordService();
    await _addWordService.initService();
    await loadDrafts();
  }
}
