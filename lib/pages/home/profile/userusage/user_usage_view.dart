import 'dart:developer';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/constants/project_colors.dart';
import 'package:subsocial/main.dart';
import 'package:subsocial/providers/theme_provider.dart';

class UserUsageView extends ConsumerStatefulWidget {
  const UserUsageView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserUsageViewState();
}

class _UserUsageViewState extends ConsumerState<UserUsageView> {
  final Duration animDuration = const Duration(milliseconds: 500);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usages'),
      ),
      body: Padding(
        padding: ProjectPaddings.gMediumPadding,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: ref.watch(themeDataProvider)
                  ? ProjectColors.white
                  : ProjectColors.black,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: ProjectPaddings.gMediumPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          'Usage Time Subsocial app',
                          style: TextStyle(
                            color: !ref.watch(themeDataProvider)
                                ? ProjectColors.white
                                : ProjectColors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'per a day',
                          style: TextStyle(
                            color: !ref.watch(themeDataProvider)
                                ? ProjectColors.white
                                : ProjectColors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 38,
                        ),
                        Expanded(
                          child: BarChart(
                            mainBarData(),
                            swapAnimationDuration: animDuration,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 25,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched
              ? Colors.amber
              : !ref.watch(themeDataProvider)
                  ? ProjectColors.white
                  : ProjectColors.black,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: ref.watch(themeDataProvider)
                ? ProjectColors.white
                : ProjectColors.black,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(
              0,
              double.parse(box?.get('usageTimeM')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 1:
            return makeGroupData(
              1,
              double.parse(box?.get('usageTimeT')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 2:
            return makeGroupData(
              2,
              double.parse(box?.get('usageTimeW')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 3:
            return makeGroupData(
              3,
              double.parse(box?.get('usageTimeTh')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 4:
            return makeGroupData(
              4,
              double.parse(box?.get('usageTimeF')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 5:
            return makeGroupData(
              5,
              double.parse(box?.get('usageTimeS')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          case 6:
            return makeGroupData(
              6,
              double.parse(box?.get('usageTimeSu')?.toString() ?? '0'),
              isTouched: i == touchedIndex,
            );
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: !ref.watch(themeDataProvider)
              ? ProjectColors.white
              : ProjectColors.black,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x.toInt()) {
              case 0:
                weekDay = 'Monday';
                break;
              case 1:
                weekDay = 'Tuesday';
                break;
              case 2:
                weekDay = 'Wednesday';
                break;
              case 3:
                weekDay = 'Thursday';
                break;
              case 4:
                weekDay = 'Friday';
                break;
              case 5:
                weekDay = 'Saturday';
                break;
              case 6:
                weekDay = 'Sunday';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              weekDay + '\n',
              TextStyle(
                color: ref.watch(themeDataProvider)
                    ? ProjectColors.white
                    : ProjectColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(
            () {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            },
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = TextStyle(
      color: !ref.watch(themeDataProvider)
          ? ProjectColors.white
          : ProjectColors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('M', style: style);
        break;
      case 1:
        text = Text('T', style: style);
        break;
      case 2:
        text = Text('W', style: style);
        break;
      case 3:
        text = Text('T', style: style);
        break;
      case 4:
        text = Text('F', style: style);
        break;
      case 5:
        text = Text('S', style: style);
        break;
      case 6:
        text = Text('S', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(show: false),
    );
  }
}
