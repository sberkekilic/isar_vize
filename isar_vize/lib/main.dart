import 'package:flutter/material.dart';
import 'http/doviz_cek.dart';

void main() {
  // Döviz kurlarını al ve uygulamayı başlat
  fetchExchangeRatesAsync();
}

void fetchExchangeRatesAsync() async {
  final exchangeRates = await fetchExchangeRates();
  runApp(MyApp(exchangeRates: exchangeRates));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> exchangeRates; // exchangeRates değişkenini tanımla

  const MyApp({required this.exchangeRates, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(exchangeRates: exchangeRates),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> exchangeRates; // exchangeRates değişkenini tanımla

  const MyHomePage({required this.exchangeRates, Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Map<String, dynamic> exchangeRates; // exchangeRates değişkenini tanımla

  @override
  void initState() {
    super.initState();
    // initState metodunda widget'tan exchangeRates değişkenini al
    exchangeRates = widget.exchangeRates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: Center(
        child: Text('Döviz Kurları: $exchangeRates'),
      ),
    );
  }
}
