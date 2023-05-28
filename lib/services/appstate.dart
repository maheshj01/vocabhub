import 'package:flutter/material.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/user.dart';

class AppState {
  final UserModel? user;
  final List<Word>? words;
  final Word? wordOfTheDay;

  const AppState({this.user, this.words,this.wordOfTheDay});

  AppState copyWith({
    List<Word>? words,
    UserModel? user,
    Word? wordOfTheDay,
  }) {
    return AppState(words: words ?? this.words, user: user ?? this.user, wordOfTheDay: wordOfTheDay ?? this.wordOfTheDay);
  }
}

class AppStateScope extends InheritedWidget {
  AppStateScope(this.data, {Key? key, required Widget child})
      : super(key: key, child: child);

  AppState data = AppState(user: UserModel(), words: []);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.data;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return data.user?.email != oldWidget.data.user?.email ||
        data.words != oldWidget.data.words || data.wordOfTheDay != oldWidget.data.wordOfTheDay;
  }
}

/// this statefule widget is required to update the state of the AppstacteScope,
/// since inherited widget is immutable
class AppStateWidget extends StatefulWidget {
  const AppStateWidget({required this.child, Key? key}) : super(key: key);

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}

class AppStateWidgetState extends State<AppStateWidget> {
  AppState _data = AppState();

  void setWords(List<Word> words) {
    if (words != _data.words) {
      setState(() {
        _data = _data.copyWith(
          words: words,
        );
      });
    }
  }

  void setUser(UserModel user) {
    setState(() {
      _data = _data.copyWith(
        user: user,
      );
    });
  }

  void setWordOfTheDay(Word word) {
    setState(() {
      _data = _data.copyWith(
        wordOfTheDay: word,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      _data,
      child: widget.child,
    );
  }
}
