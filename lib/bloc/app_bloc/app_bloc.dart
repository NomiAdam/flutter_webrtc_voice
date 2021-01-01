import 'dart:convert';

import 'package:flutter_webrtc_voice/bloc/app_bloc/app_event.dart';
import 'package:flutter_webrtc_voice/bloc/app_bloc/app_state.dart';
import 'package:flutter_webrtc_voice/models/common/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppUninitializedState());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppInitEvent) {
      final Config config = await _loadConfigurations();
      yield AppInitializedState(config: config);
    }
  }
}

Future<Config> _loadConfigurations() async {
  final Map<String, dynamic> envConfig = await _loadEnvConfig();
  String environment = 'dev';
  if (envConfig != null) {
    environment = envConfig['env'] as String ?? environment;
  }
  final String json = await _loadAsset('lib/env/$environment.json');
  return Config.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

Future<Map<String, dynamic>> _loadEnvConfig() async {
  try {
    final String rawEnvConfig = await _loadAsset('lib/env/env_config.json');
    final Map<String, dynamic> envConfig =
        jsonDecode(rawEnvConfig) as Map<String, dynamic>;
    return envConfig;
  } catch (error) {
    return null;
  }
}

Future<String> _loadAsset(String asset) {
  return rootBundle.loadString(asset);
}
