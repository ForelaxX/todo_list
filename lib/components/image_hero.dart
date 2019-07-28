import 'package:flutter/widgets.dart';

class ImageHero extends StatelessWidget {
  final String imageKey;

  const ImageHero({Key key, this.imageKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imageKey,
      child: Image.asset(imageKey),
    );
  }
}