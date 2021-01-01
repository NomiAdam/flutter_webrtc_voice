import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  @override
  List<Object> get props => <dynamic>[];
}

class AppInitEvent extends AppEvent {
  @override
  String toString() => 'AppInitEvent';
}
