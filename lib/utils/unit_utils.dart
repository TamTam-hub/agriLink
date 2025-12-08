String toShortUnit(String unit) {
  final trimmed = unit.trim();
  final noSlash = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  switch (noSlash.toLowerCase()) {
    case 'kilogram (kg)':
    case 'kilogram':
    case 'kg':
      return 'kg';
    case 'gram (g)':
    case 'gram':
    case 'g':
      return 'g';
    case 'pound (lb)':
    case 'pound':
    case 'lb':
      return 'lb';
    case 'liter (l)':
    case 'liter':
    case 'l':
      return 'L';
    case 'dozen':
      return 'dozen';
    case 'piece':
      return 'piece';
    default:
      return noSlash; // fallback to original without slash
  }
}

String formatUnitWithSlash(String unit) {
  final short = toShortUnit(unit);
  return '/$short';
}