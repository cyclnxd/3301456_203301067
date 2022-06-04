import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'constants/theme.dart';
import 'firebase_options.dart';
import 'pages/layout/view/layout_view.dart';
import 'providers/theme_provider.dart';
import 'services/navigation/navigation_service.dart';

Box? box;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  box = await Hive.openBox('themeBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Subsocial',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: NavigationService.instance.generateRoute,
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ref.watch(themeDataProvider) ? ThemeMode.dark : ThemeMode.light,
      home: const SafeArea(child: LayoutView()),
    );
  }
}
