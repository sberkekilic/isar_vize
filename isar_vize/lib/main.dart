import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'collection/dolar_tl.dart';

void main() async {
  // Isar veritabanını açın
  final isar = await Isar.open([DolarTLSchema]);

  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;

  MyApp({required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange Rates',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExchangeRatesScreen(isar: isar),
    );
  }
}

class ExchangeRatesScreen extends StatefulWidget {
  final Isar isar;

  ExchangeRatesScreen({required this.isar});

  @override
  _ExchangeRatesScreenState createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  @override
  void initState() {
    super.initState();
    //createIsarDatabaseBackup(); sadece BACKUP zamanı
  }

  @override
  void dispose() {
    widget.isar.close();
    super.dispose();
  }

  Future<void> createIsarDatabaseBackup() async {
    String targetPath = r'C:\Users\Semih Berke KILIÇ\Desktop\backup.isar'; // Specify the target path for the backup file
    File backupFile = File(targetPath);

    try {
      await widget.isar.copyToFile(backupFile.path);
      print('Isar database backup created at: ${backupFile.path}');
    } catch (e) {
      print('Failed to create Isar database backup: $e');
    }
  }


  Future<void> fetchExchangeRateData() async {
    final startDate = DateTime.parse('2023-01-01');
    final endDate = DateTime.parse('2023-04-01');

    for (var date = startDate; date.isBefore(endDate); date = date.add(Duration(days: 1))) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final url = Uri.parse('https://api.apilayer.com/exchangerates_data/$formattedDate?symbols=TRY&base=USD');
      final response = await http.get(
        url,
        headers: {'apikey': 'RrKDA74fUaO9jlZGH4whhB9bgJI7IoaM'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final rates = responseData['rates'] as Map<String, dynamic>;

        // Exchange rate verilerini Isar veritabanına ekleyin
        await widget.isar.writeTxn(() async {
          rates.entries.forEach((entry) async {
            final dolarTL = DolarTL(
              base: responseData['base'],
              currency: entry.key,
              date: responseData['date'],
              rate: entry.value.toDouble(),
            );
            widget.isar.dolarTLs.put(dolarTL);
            print('${responseData['date']} eklendi.'); // Veri eklendiğinde tarihi yazdır
            await Future.delayed(Duration(seconds: 5)); // 5 saniye bekle
          });
        });

        print('Veriler Isar veritabanına eklendi.');
      } else {
        throw Exception('API veri çekme hatası: ${response.statusCode}');
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exchange Rates'),
      ),
      body: Center(
        child: Text('Exchange Rates data will be displayed here.'),
      ),
    );
  }
}
