/// Shared input validators — reusable across sign-up, login, settings, etc.
abstract final class InputValidators {
  /// Valid email format check.
  static bool isEmailValid(String email) {
    return RegExp(r'^[\w\-.+]+@[\w\-]+\.[\w\-.]+$').hasMatch(email.trim());
  }

  /// Password has at least 8 characters.
  static bool hasMinLength(String password, [int min = 8]) {
    return password.length >= min;
  }

  /// Password contains at least one number or special character.
  static bool hasNumberOrSpecial(String password) {
    return RegExp(r'[0-9!@#\$%\^&\*\(\)_\+\-=\[\]{};:,.<>?/\\|`~]')
        .hasMatch(password);
  }

  /// Password meets all criteria.
  static bool isPasswordValid(String password) {
    return hasMinLength(password) && hasNumberOrSpecial(password);
  }

  /// Display name is at least 2 characters after trimming.
  static bool isNameValid(String name) {
    return name.trim().length >= 2;
  }
}
