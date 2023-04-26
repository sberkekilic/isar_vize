import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ExchangeRate {
  late String base;
  late DateTime date;
  late Map<String, double> rates;

  ExchangeRate({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      base: json['base'],
      date: DateTime.parse(json['date']),
      rates: Map<String, double>.from(json['rates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'date': date.toIso8601String(),
      'rates': rates,
    };
  }
}

class ExchangeRateHelper {
  late Database _db;

// Veritabanını aç
  Future<void> open() async {
    String databasesPath = await getDatabasesPath();
    String pathToDb = path.join(databasesPath, 'exchange_rates.db');
    _db = await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (Database db, int version) async {
        // ExchangeRates tablosunu oluştur
        await db.execute('''
      CREATE TABLE IF NOT EXISTS exchange_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        base TEXT,
        date TEXT,
        rates TEXT
      )
    ''');
      },
    );
  }

  // ExchangeRate verisini veritabanına ekle
  Future<void> addExchangeRate(ExchangeRate exchangeRate) async {
    await _db.insert(
      'exchange_rates',
      exchangeRate.toJson(),
    );
  }

// ExchangeRate verilerini veritabanından getir
  Future<List<ExchangeRate>> fetchExchangeRates() async {
    List<Map<String, dynamic>> maps = await _db.query('exchange_rates');
    return List.generate(
      maps.length,
      (index) {
        return ExchangeRate(
          base: maps[index]['base'],
          date: DateTime.parse(maps[index]['date']),
          rates: Map<String, double>.from(json.decode(maps[index]['rates'])),
        );
      },
    );
  }
}

// Bütün exchange rate verilerini API'den çekip veritabanına kaydet
Future<void> fetchAndSaveExchangeRates() async {
  String apiKey = 'ADnjGE18DHwWLefgBol0unVZtr7W2L2G';
  String baseUrl = 'https://api.apilayer.com/exchangerates_data';
  String symbols = 'TRY';
  String base = 'USD';
  DateTime currentDate = DateTime.now();
  DateTime startDate = DateTime(2023, 1, 1); // Başlangıç tarihi: 2023-01-01
  DateTime endDate =
      currentDate.subtract(Duration(days: 1)); // Bitiş tarihi: bugün - 1

  List<DateTime> dateRange = [];
  DateTime date = startDate;
  while (date.isBefore(endDate)) {
    dateRange.add(date);
    date = date.add(Duration(days: 1));
  }

  ExchangeRateHelper dbHelper = ExchangeRateHelper();
  await dbHelper.open();

  for (DateTime date in dateRange) {
    String formattedDate = date.toIso8601String().substring(0, 10);
    String url = '$baseUrl/$formattedDate?symbols=$symbols&base=$base';
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {'apikey': apiKey},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      bool success = jsonResponse['success'];
      if (success) {
        String base = jsonResponse['base'];
        String date = jsonResponse['date'];
        Map<String, double> rates =
            Map<String, double>.from(jsonResponse['rates']);
        ExchangeRate exchangeRate = ExchangeRate(
            base: base, date: DateTime.parse(date), rates: rates);
        await dbHelper.addExchangeRate(exchangeRate);
      }
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }
}
