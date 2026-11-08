import 'package:intl/intl.dart';

/// `3200` → `3,200`. Thousands separators per the spec, in every locale.
String formatThousands(int value) => NumberFormat('#,###', 'en').format(value);
