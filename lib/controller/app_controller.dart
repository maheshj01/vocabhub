class AppController {
  int index = 0;
  bool showFAB = true;
  bool extended = true;

  AppController({this.index = 0, this.showFAB = true,this.extended = true});

  AppController copyWith({int? index, bool? showFAB,bool? extended}) {
    return AppController(
      index: index ?? this.index,
      showFAB: showFAB ?? this.showFAB,
      extended: extended ?? this.extended,
    );
  }
}
