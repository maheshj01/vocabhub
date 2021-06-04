import 'package:flutter/material.dart';
import 'package:vocabhub/models/word_model.dart';

class WordDetail extends StatefulWidget {
  final Word? word;
  const WordDetail({Key? key, this.word}) : super(key: key);

  @override
  _WordDetailState createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late Tween<int> _tween;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    if (widget.word != null) {
      length = widget.word!.meaning.length;
    }
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // _animationController.reset();
      }
    });
  }

  int length = 0;
  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordDetail oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print('rebuilding');
    if (widget.word != null) {
      setState(() {
        length = widget.word!.meaning.length;
      });
    }
    print('end = ${_tween.end}');
    _tween.end = length;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // int length = widget.word!.word.length;
    String meaning = '';

    int start = 0;
    print('length =$length');
    return widget.word == null
        ? EmptyWord()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height / 5,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  widget.word!.word,
                  style: TextStyle(fontSize: size.height * 0.06),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              length > 0
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (BuildContext _, Widget? child) {
                          print('${_animation.value}');
                          meaning = widget.word!.meaning
                              .substring(0, _animation.value);
                          return Text(meaning, style: TextStyle(fontSize: 20));
                        },
                      ),
                    )
                  : Container(),
              // Text(widget.word!.meaning)
            ],
          );
  }
}

class EmptyWord extends StatelessWidget {
  const EmptyWord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Word Detail here',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}
