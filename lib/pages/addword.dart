import 'package:flutter/material.dart';
import 'package:vocabhub/utils/navigator.dart';

class AddWordForm extends StatefulWidget {
  const AddWordForm({Key? key}) : super(key: key);

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends State<AddWordForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: 500,
        margin: EdgeInsets.symmetric(horizontal: 32),
        color: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
                onPressed: () => popView(context),
                icon: Icon(Icons.clear, color: Colors.white)),
            Container()
          ],
        ),
      ),
    );
  }
}
