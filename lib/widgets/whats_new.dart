// Create a stateful widget called WhatsNew
// This widget is shown when the app is opened for the first time
// after the update

import 'package:flutter/material.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/widgets.dart';

class WhatsNew extends StatefulWidget {
  static const route = '/whats-new';
  @override
  _WhatsNewState createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  Future<List<List<String>>> loadAsset() async {
    final result = await DefaultAssetBundle.of(context).loadString('assets/CHANGELOG.md');
    List<List<String>> changelog = [];
    List<String> release = [];
    final lines = result.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isEmpty) continue;
      if (lines[i].startsWith('###')) {
        if (release.isNotEmpty) {
          changelog.add(release);
          release = [];
        }
        release.add(lines[i].substring(4));
      } else {
        release.add(lines[i]);
      }
    }
    print(changelog[1]);
    return changelog;
  }

  @override
  void initState() {
    super.initState();
    // Call the method that shows the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAsset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(children: [
          SizedBox(height: 10),
          Padding(
            padding: 16.0.horizontalPadding,
            child: Row(
              children: [
                Text('What\'s New', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: FutureBuilder<List<List<String>>>(
                  future: loadAsset(),
                  builder: (context, AsyncSnapshot<List<List<String>>> snapshot) {
                    if (snapshot.data == null) {
                      return LoadingWidget();
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final release = snapshot.data![index];
                          return Column(
                            children: [
                              for (int i = 0; i < release.length; i++)
                                ListTile(
                                    leading: i == 0 ? Icon(Icons.new_releases_rounded) : null,
                                    title: Text(release[i],
                                        style: TextStyle(
                                          fontSize: i == 0 ? 18 : 16,
                                          fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                                        ))),
                            ],
                          );
                        });
                  }))
        ]),
      ),
    );
  }
}
