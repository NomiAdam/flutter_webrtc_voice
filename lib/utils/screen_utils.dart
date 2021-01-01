import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

Widget withScreenUtil(BuildContext context, Widget widget) {
  ScreenUtil.init(context, designSize: Size(360, 640), allowFontScaling: true);
  return widget;
}

final Map<String, double> _breakpoints = <String, double>{
  // iPhone SE
  '2xs': 0.00,
  // iPhone 6
  'xs': 320.00,
  // iPhone 11
  'sm': 375.00,
  'md': 450.00,
  'lg': 992.00,
  'xl': 1200.00,
};

double rSize(
  BuildContext context, {
  double xs2,
  double xs,
  double sm,
  double md,
  double lg,
  double xl,
}) {
  final Map<String, double> sizes = <String, double>{
    '2xs': xs2,
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
  };
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final Orientation orientation = mediaQuery.orientation;
  double deviceWidth;
  if (orientation == Orientation.landscape) {
    deviceWidth = mediaQuery.size.height;
  } else {
    deviceWidth = mediaQuery.size.width;
  }
  return _breakpoints.entries.fold(null,
      (double acc, MapEntry<String, double> value) {
    if (sizes[value.key] != null && deviceWidth > value.value) {
      return sizes[value.key];
    } else {
      return acc;
    }
  });
}
