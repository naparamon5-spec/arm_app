import '../constants/app_constants.dart';

class FieldFormatter {
  FieldFormatter._();

  static String orEmpty(String? value) {
    if (value == null) return AppConstants.emptyField;
    if (value.trim().isEmpty) return AppConstants.emptyField;
    if (value.trim() == 'null') return AppConstants.emptyField;
    return value.trim();
  }

  static String orEmptyDouble(double? value) {
    if (value == null) return AppConstants.emptyField;
    return value.toString();
  }
}
