import '../public.dart';
import 'package:flutter/material.dart';

//加载网络图片
class LoadNetworkImage extends StatelessWidget {
  LoadNetworkImage(this.name,
      {Key key,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.color,
      this.scale})
      : super(key: key);

  final String name;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      name,
      height: height,
      width: width,
      fit: fit,
      color: color,
      scale: scale,
    );
  }
}
