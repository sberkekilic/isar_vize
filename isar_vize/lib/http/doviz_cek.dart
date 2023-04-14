import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

import '../collection/exchange_rate.dart';

Future<Map<String, dynamic>> fetchExchangeRates() async {
  final response = await http.get(Uri.parse(
      'https://api.collectapi.com/economy/currencyToAll?int=10&base=USD'));
  if (response.statusCode == 200) {
    // JSON veriyi çözme
    final Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Döviz kurları alınamadı');
  }
}
