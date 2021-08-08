import 'package:flutter/material.dart';

class CircularAvatar extends StatelessWidget {
  final String? name;
  final Function? onTap;
  final String? url;
  final double radius;

  const CircularAvatar(
      {Key? key, this.name, this.onTap, this.url, this.radius = 32.0})
      : assert(name != null || url != null, 'name or url cannot be null'),
        super(key: key);

  ImageProvider getImageProvider(String imagePath) {
    if (imagePath.contains('assets/')) {
      return AssetImage(imagePath);
    } else {
      return NetworkImage(imagePath);
    }
  }

  String getInitial(String text) {
    if (text != null || text.contains(' ')) {
      final list = text.split(' ').toList();
      return list[0].substring(0, 1) + list[1].substring(0, 1);
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap!(),
      child: CircleAvatar(
          radius: radius,
          foregroundColor: Colors.white,
          backgroundImage: url == null ? null : getImageProvider(url!),
          backgroundColor: Colors.red,
          child: url == null
              ? Text(getInitial(name!),
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold))
              : null),
    );
  }
}
