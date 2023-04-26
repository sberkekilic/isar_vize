import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../collection/dolar_tl.dart';

class DolarChartPage extends StatefulWidget {
  final List<DolarTL> dolarList;
  const DolarChartPage({Key? key, required this.dolarList, required Isar isar}) : super(key: key);

  @override
  _DolarChartPageState createState() => _DolarChartPageState();
}

class _DolarChartPageState extends State<DolarChartPage> {
  late List<_ChartData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _chartData = widget.dolarList.map((dolar) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final dateTime = dateFormat.parse(dolar.date!);
      return _ChartData(dateTime, dolar.rate ?? 0.0);
    }).toList();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dolar Chart'),
      ),
      body: SfCartesianChart(
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: DateTimeAxis(),
        series: <ChartSeries<_ChartData, DateTime>>[
          LineSeries<_ChartData, DateTime>(
            dataSource: _chartData,
            xValueMapper: (_ChartData data, _) => data.date,
            yValueMapper: (_ChartData data, _) => data.rate,
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final DateTime date;
  final double rate;
  _ChartData(this.date, this.rate);
}
