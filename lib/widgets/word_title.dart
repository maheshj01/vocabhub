import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/controller/app_controller.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/collections/list_collections.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/extensions.dart';

class WordTitleBuilder extends ConsumerStatefulWidget {
  final Word word;
  final bool hasFloatingActionButton;
  const WordTitleBuilder({super.key, required this.word, this.hasFloatingActionButton = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WordTitleBuilderState();
}

class _WordTitleBuilderState extends ConsumerState<WordTitleBuilder> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{Constants.collectionsFeature},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = ref.watch(userNotifierProvider);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: "${widget.word.word}"));
        NavbarNotifier.showSnackBar(context, " copied ${widget.word.word} to clipboard.",
            bottom: widget.hasFloatingActionButton ? 0 : kNavbarHeight);
      },
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Row(
          children: [
            Padding(
              padding: 16.0.horizontalPadding,
              child: Text(widget.word.word.capitalize()!,
                  style: VocabTheme.googleFontsTextTheme.displaySmall!),
            ),
            userProvider.isLoggedIn
                ? DescribedFeatureOverlay(
                    featureId: Constants.collectionsFeature,
                    tapTarget: Icon(Icons.bookmark_add, size: 26, color: colorScheme.surfaceTint),
                    title: Text('Save to Collections'),
                    description: Text('Save this word to your collections'),
                    backgroundColor: Theme.of(context).primaryColor,
                    targetColor: colorScheme.onPrimary,
                    textColor: colorScheme.onPrimary,
                    child: IconButton(
                        onPressed: () async {
                          final AppController state = ref.read(appNotifier.notifier).state;
                          ref.watch(appNotifier.notifier).state = state.copyWith(showFAB: false);
                          if (size.width < 600) {
                            NavbarNotifier.hideBottomNavBar = true;
                          }
                          await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                    maxChildSize: 0.8,
                                    initialChildSize: 0.8,
                                    expand: false,
                                    builder: (context, controller) {
                                      return CollectionsNavigator(
                                        controller: controller,
                                        word: widget.word,
                                      );
                                    });
                              });
                          ref.watch(appNotifier.notifier).state = state.copyWith(showFAB: true);
                          NavbarNotifier.hideBottomNavBar = false;
                        },
                        icon: Icon(
                          Icons.bookmark_add,
                          size: 26,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        )),
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
