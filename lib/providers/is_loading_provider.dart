import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateNotifierProvider<Loading, bool>((ref) {
  return Loading();
});

class Loading extends StateNotifier<bool> {
  Loading() : super(false);

  void changeIsLoading() {
    state = !state;
  }
}
