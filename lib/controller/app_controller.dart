class AppController {
  int index = 0;
  bool showFAB = true;

  AppController({this.index = 0, this.showFAB = true});

  AppController copyWith({int? index, bool? showFAB}) {
    return AppController(
      index: index ?? this.index,
      showFAB: showFAB ?? this.showFAB,
    );
  }
}
