import 'package:flutter_webrtc_voice/models/common/config.dart';
import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => <dynamic>[];
}

class AppUninitializedState extends AppState {
  @override
  String toString() => 'AppUninitializedState';
}

class AppInitializedState extends AppState {
  final Config config;

  AppInitializedState({this.config});

  @override
  String toString() => 'AppInitializedState {Config: $config}';

  @override
  List<Object> get props => <Config>[config];
}
