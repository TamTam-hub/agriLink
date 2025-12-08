import 'package:flutter/widgets.dart';

class Responsive {
  static late double _width;
  static late double _height;
  static late double _textScale;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _width = mq.size.width;
    _height = mq.size.height;
    _textScale = mq.textScaler.scale(1.0);
  }

  static double w(double percent) => _width * percent / 100;
  static double h(double percent) => _height * percent / 100;
  static double sp(double size) {
    final widthFactor = (_width / 390).clamp(0.9, 1.05);
    final scaled = size * widthFactor;
    final withTextScale = scaled * (1 + (_textScale - 1) * 0.5);
    return withTextScale.clamp(size * 0.85, size * 1.15);
  }
}

extension ResponsiveContext on BuildContext {
  double rw(double percent) => Responsive.w(percent);
  double rh(double percent) => Responsive.h(percent);
  double rsp(double size) => Responsive.sp(size);
}