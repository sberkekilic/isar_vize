import 'package:isar/isar.dart';
part 'exchange_rate.g.dart';

@Collection()
class ExchangeRate {
  Id id = Isar.autoIncrement;
  String? currency;
  double? rate;
}
