import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/themes/theme_selector.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NewCollection extends ConsumerStatefulWidget {
  static const String route = '/new';
  final bool isPinned;
  const NewCollection({Key? key, this.isPinned = false}) : super(key: key);
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

  Color selected = Colors.primaries[0];
  @override
  Widget build(BuildContext context) {
    final collectionRef = ref.watch(collectionNotifier);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text('New Collection'),
          ),
          body: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VHTextfield(
                hint: 'Collection Name',
                controller: _controller,
                autoFocus: true,
                hasLabel: false,
              ),
              16.0.vSpacer(),
              Padding(
                padding: 16.0.horizontalPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading('Select a color', color: Theme.of(context).colorScheme.primary),
                    ThemeSelector(
                        colors: Colors.primaries,
                        value: selected,
                        onThemeChanged: (val) {
                          setState(() {
                            selected = val;
                          });
                        }),
                  ],
                ),
              ),
              32.0.vSpacer(),
              Column(
                children: [
                  32.0.vSpacer(),
                  VHButton(
                      height: 48,
                      width: 200,
                      fontSize: 16,
                      onTap: () {
                        final title = _controller.text.trim();
                        if (title.isNotEmpty) {
                          final newCollection =
                              VHCollection.init(pinned: false, title: title, color: selected);
                          collectionRef.addCollection(newCollection);
                          Navigator.pop(context);
                        } else {
                          NavbarNotifier.showSnackBar(context, 'Collection name cannot be empty');
                        }
                      },
                      label: 'Create Collection'),
                  32.0.vSpacer(),
                  Text("$onDeviceCollectionsString",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5))),
                ],
              ),
              16.0.vSpacer()
            ],
          )),
    );
  }
}
