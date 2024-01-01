import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/profile/profile.dart';
import 'package:vocabhub/pages/notifications/notification_detail.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';

class EditExpansionDetail extends StatelessWidget {
  final EditHistory currentEdit;
  final EditHistory lastApprovedEdit;

  EditExpansionDetail(this.currentEdit, this.lastApprovedEdit);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: CircularAvatar(
        name: currentEdit.users_mobile!.name,
        url: currentEdit.users_mobile!.avatarUrl,
      ),
      title: Text(currentEdit.word),
      iconColor: Colors.red,
      onExpansionChanged: (x) {},
      subtitle: Text(currentEdit.created_at!.toLocal().standardDateTime()),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: ${currentEdit.state!.name.capitalize()!}',
            style: TextStyle(
              color: stateToIconColor(currentEdit.state!),
            ),
          ),
          Text('Type: ${currentEdit.edit_type!.name.capitalize()!}'),
        ],
      ),
      children: [
        DifferenceVisualizer(
            title: 'Word', newVersion: currentEdit.word, oldVersion: lastApprovedEdit.word),
        DifferenceVisualizer(
            title: 'Meaning',
            newVersion: currentEdit.meaning,
            oldVersion: lastApprovedEdit.meaning),
        DifferenceVisualizer(
            title: 'Synonyms',
            newVersion: currentEdit.synonyms!.join(','),
            oldVersion: lastApprovedEdit.synonyms!.join(',')),
        DifferenceVisualizer(
            title: 'Examples',
            newVersion: currentEdit.examples!.join(','),
            oldVersion: lastApprovedEdit.examples!.join(',')),
        DifferenceVisualizer(
            title: 'Mnemonics',
            newVersion: currentEdit.mnemonics!.join(','),
            oldVersion: lastApprovedEdit.mnemonics!.join(',')),
        ListTile(
          title: Text('Comments'),
          subtitle: Text(currentEdit.comments),
        ),
        ListTile(
            title: Text('Edited By'),
            subtitle: Text(currentEdit.users_mobile!.name),
            onTap: () {
              Navigate.push(
                  context,
                  Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: false,
                        title: Text(
                          'Profile',
                        ),
                      ),
                      body: UserProfile(
                        email: currentEdit.users_mobile!.email,
                        isReadOnly: true,
                      )));
            },
            trailing: Icon(
              Icons.arrow_forward_ios,
            )),
      ],
    );
  }
}
