import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:isar_vize/pages/dolar-chart-page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../collection/dolar_tl.dart';

class DolarPage extends StatefulWidget {
  final Isar isar;

  const DolarPage({Key? key, required this.isar}) : super(key: key);

  @override
  State<DolarPage> createState() => _DolarPageState();
}

class _DolarPageState extends State<DolarPage> {
  List<DolarTL> _dolarList = [];
  DateTime _selectedDate = DateTime.now();
  double _selectedRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDolarData();
  }

  Future<void> _loadDolarData() async {
    final dolarList = await widget.isar.dolarTLs.where().sortByDate().findAll();
    setState(() {
      _dolarList = dolarList;
      final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final selectedDolar = _dolarList.firstWhere(
            (d) => d.date == selectedDateString,
        orElse: () => DolarTL(rate: null),
      );
      _selectedRate = selectedDolar.rate ?? 0.0;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        _selectedDate = args.value!;
        final dateFormat = DateFormat('yyyy-MM-dd');
        final selectedDateString = dateFormat.format(_selectedDate);
        final selectedDolar = _dolarList.firstWhere(
          (d) => d.date == selectedDateString,
          orElse: () => DolarTL(rate: null),
        );
        _selectedRate = selectedDolar.rate ?? 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dolar List'),
        ),
        body: Column(children: [
          SfDateRangePicker(
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedRange: PickerDateRange(
              DateTime(2023, 01, 01),
              DateTime(2023, 02, 01),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Selected rate: $_selectedRate',
            style: TextStyle(fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () =>
                context.go('/dolar/grafik', extra: {'dolarList': '_dolarList', 'isar': 'widget.isar'}),
            child: Text('Grafik'),
          )
        ]));
  }
}
