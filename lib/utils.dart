import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initializeLocale() async {
  await initializeDateFormatting('fr_FR', null);
}

String formatCurrency(double amount, String currency) {
  NumberFormat formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: currency,
    decimalDigits: 0,
  );
  return formatter.format(amount);
}
