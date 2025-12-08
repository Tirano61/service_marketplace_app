class Validators {
  Validators._();

  static bool isValidEmail(String value) {
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    return RegExp(pattern).hasMatch(value.trim());
  }

  static bool isNotEmpty(String value) => value.trim().isNotEmpty;
}
