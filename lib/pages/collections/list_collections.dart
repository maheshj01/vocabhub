import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/empty_page.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

import 'new_collections.dart';

class CollectionsNavigator extends StatefulWidget {
  final Word word;
  final ScrollController? controller;
  const CollectionsNavigator({super.key, required this.word, this.controller});

  @override
  State<CollectionsNavigator> createState() => _CollectionsNavigatorState();
}

class _CollectionsNavigatorState extends State<CollectionsNavigator> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case NewCollection.route:
              return MaterialPageRoute(builder: (context) => NewCollection());
            case CollectionDetails.route:
              final title = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (context) => CollectionDetails(
                        title: title,
                      ));
            case CollectionsGrid.route:
              return MaterialPageRoute(
                  builder: (context) => CollectionsGrid(
                        controller: widget.controller,
                      ));
            default:
              return MaterialPageRoute(
                  builder: (context) => SavedCollections(
                        controller: widget.controller,
                        word: widget.word,
                      ));
          }
        },
      ),
    );
  }
}

class SavedCollections extends ConsumerStatefulWidget {
  final ScrollController? controller;
  final Word word;
  const SavedCollections({super.key, this.controller, required this.word});

  @override
  ConsumerState<SavedCollections> createState() => _CollectionsSavedState();
}

class _CollectionsSavedState extends ConsumerState<SavedCollections> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionNotifier).collections;
    return Column(
      children: [
        Padding(
          padding: 8.0.topPadding + 4.0.bottomPadding,
          child: ListTile(
            title: Text('Collections', style: Theme.of(context).textTheme.headlineSmall),
            trailing: TextButton(
                onPressed: () {
                  Navigate.pushNamed(context, '/new');
                },
                child: Text('Create Collection',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary))),
          ),
        ),
        hLine(),
        if (collections.isEmpty)
          Expanded(child: EmptyPage(message: 'No collections found'))
        else
          Expanded(
              child: ListView.builder(
                  itemCount: collections.length,
                  controller: widget.controller ?? ScrollController(),
                  itemBuilder: (context, index) {
                    final title = collections.keys.elementAt(index);
                    final values = collections.values.elementAt(index);
                    final contains = values.containsWord(widget.word);
                    return ListTile(
                      title: Text('$title (${values.length})'),
                      onTap: () {
                        Navigate.pushNamed(
                          context,
                          CollectionDetails.route,
                          arguments: '$title',
                        );
                      },
                      trailing: widget.word.word.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () async {
                                if (contains) {
                                  ref
                                      .read(collectionNotifier.notifier)
                                      .removeFromCollection(title, widget.word);
                                } else {
                                  ref
                                      .read(collectionNotifier.notifier)
                                      .addToCollection(title, widget.word);
                                }
                              },
                              icon:
                                  Icon(contains ? Icons.check : Icons.add_circle_outline_outlined)),
                    );
                  })),
      ],
    );
  }
}

class CollectionsGrid extends ConsumerStatefulWidget {
  final ScrollController? controller;
  static const String route = '/collections';
  const CollectionsGrid({super.key, this.controller});

  @override
  ConsumerState<CollectionsGrid> createState() => CollectionsGridState();
}

class CollectionsGridState extends ConsumerState<CollectionsGrid> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionNotifier).collections;
    return collections.isEmpty
        ? EmptyPage(message: 'No collections found')
        : GridView.builder(
            padding: 8.0.verticalPadding,
            itemCount: collections.length,
            controller: widget.controller ?? ScrollController(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
            itemBuilder: (context, index) {
              final title = collections.keys.elementAt(index);
              final values = collections.values.elementAt(index);
              return Card(
                color: Theme.of(context).colorScheme.primary,
                child: InkWell(
                  onTap: () {
                    Navigate.pushNamed(context, '/new');
                    // Navigate.pushNamed(context, CollectionDetails.route, arguments: '$title');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$title (${values.length})',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text('Tap to view', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}

class CollectionDetails extends ConsumerStatefulWidget {
  // collection name
  final String title;
  static const String route = '/collection/details';
  const CollectionDetails({super.key, required this.title});

  @override
  ConsumerState<CollectionDetails> createState() => _CollectionDetailsState();
}

class _CollectionDetailsState extends ConsumerState<CollectionDetails> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionNotifier).collections;
    final values = collections[widget.title] ?? [];
    return Column(
      children: [
        Padding(
          padding: 8.0.topPadding + 4.0.bottomPadding,
          child: ListTile(
            leading: BackButton(),
            title: Text('${widget.title}', style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        hLine(),
        if (values.isEmpty)
          Expanded(child: EmptyPage(message: 'No words in ${widget.title}'))
        else
          Expanded(
              child: ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    final word = values[index];
                    return ListTile(
                      title: Text('${word.word.capitalize()}'),
                      onTap: () {
                        Navigate.push(context, WordDetail(word: word),
                            isRootNavigator: true, transitionType: TransitionType.rtl);
                      },
                      trailing: IconButton(
                          onPressed: () {
                            //  push on top of the stack
                            Navigate.push(context, WordDetail(word: word),
                                isRootNavigator: true, transitionType: TransitionType.rtl);
                          },
                          icon: Icon(Icons.arrow_forward_ios_outlined)),
                    );
                  })),
      ],
    );
  }
}
