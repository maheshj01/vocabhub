import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/button.dart';

class NewCollection extends ConsumerStatefulWidget {
  static const String route = '/new';
  const NewCollection({Key? key}) : super(key: key);
  @override
  ConsumerState<NewCollection> createState() => _NewCollectionState();
}

class _NewCollectionState extends ConsumerState<NewCollection> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionRef = ref.watch(collectionNotifier);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text('New Collection'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VHTextfield(
              hint: 'Collection Name',
              controller: _controller,
              hasLabel: false,
            ),
            Column(
              children: [
                VHButton(
                    height: 48,
                    width: 200,
                    fontSize: 16,
                    onTap: () {
                      final title = _controller.text.trim();
                      if (title.isNotEmpty) {
                        collectionRef.addCollection(title);
                        Navigator.pop(context);
                      }
                    },
                    label: 'Create Collection'),
                16.0.vSpacer(),
                Text("$onDeviceCollectionsString",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5))),
              ],
            ),
            16.0.vSpacer()
          ],
        ));
  }
}
