import 'package:flutter/material.dart';

import '../services/navigation/navigation_service.dart';

class NotFoundNavigationWidget extends StatelessWidget {
  const NotFoundNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Upss, wrong direction go back home!"),
            ElevatedButton(
              onPressed: () {
                NavigationService.instance.navigateToPageClear(path: "/home");
              },
              child: const Text("Go home"),
            )
          ],
        ),
      ),
    );
  }
}
