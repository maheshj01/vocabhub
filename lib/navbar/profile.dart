import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  static const String route = '/';
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('User Profile'),
        ));
  }
}

class UserProfileMobile extends StatelessWidget {
  static const String route = '/';
  const UserProfileMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('User Profile Mobile'),
        ));
  }
}

class UserProfileDesktop extends StatelessWidget {
  static const String route = '/';
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Desktop'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 20,
          itemBuilder: (BuildContext context, int x) {
            return ListTile(
              title: Text('item $x'),
            );
          }),
    );
  }
}
