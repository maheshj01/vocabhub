import 'package:flutter/material.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/utils/utils.dart';

class MnemonnicBuilder extends StatefulWidget {
  final List<String>? mnemonics;
  final String word;
  const MnemonnicBuilder(
      {Key? key, required this.mnemonics, required this.word})
      : super(key: key);

  @override
  _MnemonnicBuilderState createState() => _MnemonnicBuilderState();
}

class _MnemonnicBuilderState extends State<MnemonnicBuilder> {
  Widget buildMnemonic(String mnemonic) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: SelectableText('- $mnemonic',
          style: Theme.of(context).textTheme.headline5),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = SizeUtils.isMobile;
    bool isDark = darkNotifier.value;
    return widget.mnemonics!.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mnemonic',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: isMobile ? 18 : 24,
                    color: isDark ? Colors.white : Colors.black),
              ),
              SizedBox(
                height: 16,
              ),
              ...[
                for (int i = 0; i < widget.mnemonics!.length; i++)
                  buildMnemonic(widget.mnemonics![i])
              ]
            ],
          );
  }
}
