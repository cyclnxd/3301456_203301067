import 'package:flutter/material.dart';
import 'package:subsocial/main.dart';
import 'package:subsocial/pages/layout/view/layout_view.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({Key? key}) : super(key: key);

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  DateTime startTime = DateTime(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startTime = DateTime.now();
    }

    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      var usageTime = DateTime.now().difference(startTime);
      switch (DateTime.now().weekday) {
        case DateTime.monday:
          box?.put(
            'usageTimeM',
            (box?.get('usageTimeM') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.tuesday:
          box?.put(
            'usageTimeT',
            (box?.get('usageTimeT') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.wednesday:
          box?.put(
            'usageTimeW',
            (box?.get('usageTimeW') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.thursday:
          box?.put(
            'usageTimeTh',
            (box?.get('usageTimeTh') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.friday:
          box?.put(
            'usageTimeF',
            (box?.get('usageTimeF') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.saturday:
          box?.put(
            'usageTimeS',
            (box?.get('usageTimeS') ?? 0) + usageTime.inMinutes,
          );
          break;
        case DateTime.sunday:
          box?.put(
            'usageTimeSu',
            (box?.get('usageTimeSu') ?? 0) + usageTime.inMinutes,
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LayoutView(),
    );
  }
}
