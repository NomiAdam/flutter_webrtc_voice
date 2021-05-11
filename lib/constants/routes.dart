import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc_voice/screens/login_screen.dart';
import 'package:flutter_webrtc_voice/screens/select_opponents_screen.dart';

final Map<String, Widget Function(BuildContext context)> routes =
    <String, Widget Function(BuildContext context)>{
  describeEnum(Routes.login): (BuildContext context) => LoginScreen(),
  describeEnum(Routes.select_opponent): (BuildContext context) =>
      SelectOpponentsScreen(),
};

enum Routes {
  login,
  select_opponent,
}
