import 'types.dart';

abstract class ConnectionOptions {
  late int gasInflationFactor;
  late String gasPrice;
  Address? feeCurrency;
  Address? address;
}


