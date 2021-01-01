import 'package:flutter_webrtc_voice/utils/logger_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object event) {
    super.onEvent(bloc, event);
    logger.d(event);
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    logger.d(transition);
  }

  @override
  void onError(Cubit<dynamic> cubit, Object error, StackTrace stacktrace) {
    super.onError(cubit, error, stacktrace);
    logger.e(error);
  }
}
