import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage_service.dart';
import 'core/services/workout_timer_service.dart';
import 'core/services/foldable_device_service.dart';
import 'state/app_state.dart';
import 'screens/main_navigation_screen.dart';
import 'widgets/foldable_easter_egg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  await storageService.init();

  final timerService = WorkoutTimerService();
  await timerService.init();

  final foldableService = FoldableDeviceService();
  await foldableService.init();

  final appState = AppState(storage: storageService);

  runApp(GymBroApp(appState: appState));
}

class GymBroApp extends StatefulWidget {
  final AppState appState;

  const GymBroApp({super.key, required this.appState});

  @override
  State<GymBroApp> createState() => _GymBroAppState();
}

class _GymBroAppState extends State<GymBroApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/app_logo_small.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymBro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final locale = Localizations.maybeLocaleOf(context);
        final isRtl = locale?.languageCode != 'en';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: FoldableEasterEggOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: MainNavigationScreen(state: widget.appState),
    );
  }
}
