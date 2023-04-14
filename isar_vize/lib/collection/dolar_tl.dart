import 'package:isar/isar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'dolar_tl.g.dart';

// Isar veritabanı modeli
@Collection()
class DolarTL {
  Id id = Isar.autoIncrement;
  String? base;
  String? currency;
  String? date;
  double? rate;

  DolarTL({this.base, this.currency, this.date, this.rate});
}

// Isar veritabanını oluşturma ve döviz kuru veri eklemek için kullanılan fonksiyon
void createIsarDatabaseAndAddExchangeRateData() async {
  // Isar veritabanınızı açın
  final isar = await Isar.open( [DolarTLSchema]
  );

  // API'den veri çekme
  final url = Uri.parse('https://api.apilayer.com/exchangerates_data/2023-01-01?symbols=TRY&base=USD');
  final response = await http.get(
    url,
    headers: {'apikey': 'ADnjGE18DHwWLefgBol0unVZtr7W2L2G'},
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final rates = responseData['rates'] as Map<String, dynamic>;

    // Exchange rate verilerini Isar veritabanına ekleyin
    rates.entries.forEach((entry) {
      final dolarTL = DolarTL(
        base: responseData['base'],
        currency: entry.key,
        date: responseData['date'],
        rate: entry.value.toDouble(),
      );
      isar.writeTxn(() async {
        await isar.dolarTLs.put(dolarTL);
      });
    });

    print('Veriler Isar veritabanına eklendi.');
  } else {
    throw Exception('API veri çekme hatası: ${response.statusCode}');
  }
}
