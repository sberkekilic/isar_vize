import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyPage extends StatefulWidget {
  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  bool isLoading = true;
  bool isError = false;
  List<Map<String, dynamic>>? exchangeRatesList;

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    try {
      // Set the API endpoint URL
      String apiKey = 'ADnjGE18DHwWLefgBol0unVZtr7W2L2G';
      String baseUrl = 'https://api.apilayer.com/exchangerates_data/';
      String symbols = 'TRY';
      String base = 'USD';
      DateTime startDate = DateTime(2023, 4, 1); // Başlangıç tarihi: 2023-01-01
      DateTime endDate = DateTime.now(); // Şu anki tarih
      String url = '';

      // Fetch exchange rate data for each date within the date range
      List<Map<String, dynamic>> exchangeRates = [];
      while (startDate.isBefore(endDate)) {
        String formattedDate = startDate.toIso8601String().substring(0, 10);
        url = '$baseUrl$formattedDate?symbols=$symbols&base=$base';

        // Send GET request to fetch exchange rate data
        http.Response response = await http.get(
          Uri.parse(url),
          headers: {'apikey': apiKey},
        );

        // Check if response is successful
        if (response.statusCode == 200) {
          // Parse response body as JSON
          Map<String, dynamic> data = json.decode(response.body);

          exchangeRates.add(data);
        } else {
          print('Failed to fetch exchange rate data for date: $formattedDate. Status code: ${response.statusCode}');
        }

        startDate = startDate.add(Duration(days: 1)); // Sonraki günü işle
      }

      setState(() {
        isLoading = false;
        isError = false;
        exchangeRatesList = exchangeRates;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print('Failed to fetch exchange rate data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Currency Exchange Rates'),
        ),
        body: Center(
        child: isLoading
        ? CircularProgressIndicator()
        : isError
    ? Text('Failed to fetch exchange rate data')
        : Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Expanded(
    child: ListView.builder(
    itemCount: exchangeRatesList!.length,
    itemBuilder: (BuildContext context, int index) {
    Map<String, dynamic> exchangeRateData = exchangeRatesList![index];
    return ListTile(
    title: Text('Date: ${exchangeRateData['date']}'),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Base: ${exchangeRateData['base']}'),
    Text('Rates:'),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: (exchangeRateData['rates'] as Map<String, dynamic>)
        .entries
        .map((entry) => Text('${entry.key}: ${entry.value}'))
        .toList(),
    ),
    ],
    ),
    );
    },
    ),
    ),
    ],
    ),
    ));
  }
}

