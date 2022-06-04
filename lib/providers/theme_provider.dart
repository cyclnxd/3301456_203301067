import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

final themeDataProvider = StateNotifierProvider<ThemeState, bool>(
  (ref) {
    return ThemeState();
  },
);

class ThemeState extends StateNotifier<bool> {
  ThemeState() : super(box?.get('isDark', defaultValue: false));

  void changeTheme() {
    state = !state;
    box?.put('isDark', state);
  }
}
