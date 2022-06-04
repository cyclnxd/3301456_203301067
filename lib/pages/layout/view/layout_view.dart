import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/loading.dart';
import '../../../components/not_found_widget.dart';
import '../../../providers/firebase_provider.dart';
import '../../authentication/login/view/login_view.dart';
import '../../home/home_view.dart';

final _authChangesStreamProvider = StreamProvider((ref) {
  return ref.watch(authServicesProvider).authStateChanges;
});

class LayoutView extends ConsumerWidget {
  const LayoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_authChangesStreamProvider).when(
      data: (value) {
        if (value != null) {
          return const HomePageView();
        }
        return const LoginView();
      },
      loading: <Widget>() {
        return const Loading();
      },
      error: <Widget>(_, __) {
        return const NotFoundNavigationWidget();
      },
    );
  }
}
