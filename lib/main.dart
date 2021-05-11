import 'package:connectycube_sdk/connectycube_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc_voice/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_webrtc_voice/bloc/app_bloc/app_event.dart';
import 'package:flutter_webrtc_voice/bloc/app_bloc/app_state.dart';
import 'package:flutter_webrtc_voice/bloc/simple_bloc_observer.dart';
import 'package:flutter_webrtc_voice/constants/configs.dart' as config;
import 'package:flutter_webrtc_voice/constants/routes.dart';
import 'package:flutter_webrtc_voice/theme/theme_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/namespace_file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: NamespaceFileTranslationLoader(
      namespaces: <String>[
        'common',
      ],
      useCountryCode: false,
      fallbackDir: 'en',
      basePath: 'i18n',
      forcedLocale: Locale('en'),
    ),
    missingTranslationHandler: (String key, Locale locale) {
      print('--- Missing Key: $key, languageCode: ${locale.languageCode}');
    },
  );
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider<AppBloc>(
    create: (BuildContext context) => AppBloc()..add(AppInitEvent()),
    child: App(flutterI18nDelegate),
  ));
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  App(this.flutterI18nDelegate);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      services.SystemChrome.setPreferredOrientations(
          <services.DeviceOrientation>[services.DeviceOrientation.portraitUp]);
    } else {
      services.SystemChrome
          .setPreferredOrientations(<services.DeviceOrientation>[
        services.DeviceOrientation.portraitUp,
        services.DeviceOrientation.landscapeLeft,
        services.DeviceOrientation.landscapeRight,
        services.DeviceOrientation.portraitDown,
      ]);
    }
    return ScreenUtilInit(
      designSize: Size(360, 640),
      builder: () => MaterialApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          widget.flutterI18nDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        builder: (BuildContext context, Widget child) {
          return BlocBuilder<AppBloc, AppState>(
            builder: (BuildContext context, AppState appState) {
              if (appState is AppInitializedState) {
                return child;
              } else if (appState is AppUninitializedState) {
                return SizedBox.shrink();
              } else {
                return SizedBox.shrink();
              }
            },
          );
        },
        title: 'CodeGrowers',
        theme: mainTheme,
        initialRoute: describeEnum(Routes.login),
        navigatorKey: appNavigatorKey,
        routes: routes,
      ),
    );
  }
}
