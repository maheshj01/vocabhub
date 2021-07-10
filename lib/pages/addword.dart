import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/widgets/widgets.dart';

class AddWordForm extends StatefulWidget {
  const AddWordForm({Key? key}) : super(key: key);

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends State<AddWordForm> {
  late Size size;

  Widget questionWidget(String question) {
    return Text('$question', style: Theme.of(context).textTheme.headline5);
  }

  late TextEditingController wordController;
  late TextEditingController meaningController;
  late TextEditingController exampleController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wordController = TextEditingController();
    meaningController = TextEditingController();
    exampleController = TextEditingController();
    wordController.addListener(() {
      setState(() {
        word = wordController.text;
      });
    });
    exampleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    wordController.dispose();
    meaningController.dispose();
    exampleController.dispose();
  }

  String word = '';
  List<String> _examples = [];
  int count = 0;
  int maxCount = 3;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              height: size.width < MOBILE_WIDTH ? size.height * 0.8 : null,
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16),
                      child: IconButton(
                          onPressed: () => popView(context),
                          icon: Icon(Icons.clear, size: 32)),
                    ),
                  ),
                  Center(
                    child: Text('Lets add a new word',
                        style: Theme.of(context)
                            .textTheme
                            .headline3!
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  VocabField(
                    autofocus: true,
                    fontSize: 22,
                    maxlength: 20,
                    hint: 'e.g AMBIVALENT',
                    controller: wordController,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: VocabField(
                      hint: 'What does ' +
                          '${word.isEmpty ? 'it mean?' : word + ' mean?'}',
                      controller: meaningController,
                      maxlines: 4,
                    ),
                  ),
                  ...List.generate(_examples.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: buildExample(_examples[index], word)),
                          GestureDetector(
                              onTap: () {
                                bool removed = _examples
                                    .remove(_examples.elementAt(index));
                                setState(() {});
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.delete),
                              ))
                        ],
                      ),
                    );
                  }),
                  _examples.length < maxCount
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: VocabField(
                                hint:
                                    'An example sentence ${word.isEmpty ? "" : "with $word"} (Optional)',
                                controller: exampleController,
                                maxlines: 4,
                              ),
                            ),
                            exampleController.text.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16, top: 8),
                                    child: IconButton(
                                        onPressed: () {
                                          String text = exampleController.text;
                                          if (text.isNotEmpty &&
                                              count < maxCount &&
                                              word.isNotEmpty) {
                                            _examples.add(text);
                                          }
                                          setState(() {});
                                          exampleController.clear();
                                        },
                                        icon: Icon(Icons.done, size: 32)),
                                  )
                                : Container(),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: 50,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      isDark ? Colors.teal : primaryColor)),
                          onPressed: () {},
                          child: Text('Submit',
                              style: TextStyle(color: Colors.black)))),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VocabField extends StatefulWidget {
  final String hint;
  final int? maxlines;
  final int? maxlength;
  final bool autofocus;
  final double fontSize;
  final TextEditingController controller;

  const VocabField(
      {Key? key,
      required this.hint,
      this.maxlines = 1,
      this.maxlength,
      required this.controller,
      this.fontSize = 16,
      this.autofocus = false})
      : super(key: key);

  @override
  VocabFieldState createState() => VocabFieldState();
}

class VocabFieldState extends State<VocabField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: widget.controller,
              maxLines: widget.maxlines,
              textAlign: TextAlign.center,
              maxLength: widget.maxlength,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                  hintText: widget.hint,
                  counterText: '',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: widget.fontSize),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.bold, fontSize: widget.fontSize)),
        ],
      ),
    );
  }
}
