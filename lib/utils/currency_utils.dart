String formatCurrency(String price) {
  if (price.isEmpty) return '0 ₫';
  final buffer = StringBuffer();
  final reversedPrice = price.split('').reversed.toList();
  for (int i = 0; i < reversedPrice.length; i++) {
    buffer.write(reversedPrice[i]);
    if ((i + 1) % 3 == 0 && i != reversedPrice.length - 1) {
      buffer.write('.');
    }
  }
  return '${buffer.toString().split('').reversed.join()} ₫';
}

String formatCurrencyDouble(double price) {
  return formatCurrency(price.toStringAsFixed(0));
}
