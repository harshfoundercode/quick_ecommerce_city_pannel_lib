/// 📧 Email & Input Validators
/// 
/// Reusable validation functions for forms
class Validators {
  
  /// ✅ Email Validation
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final email = value.trim();

    // 1. Check minimum length
    if (email.length < 5) {
      return 'Email is too short';
    }

    // 2. Check maximum length
    if (email.length > 100) {
      return 'Email is too long';
    }

    // 3. Should contain @ symbol
    if (!email.contains('@')) {
      return 'Email must contain @ symbol';
    }

    // 4. Should contain domain
    if (!email.contains('.')) {
      return 'Email must contain domain (e.g., .com)';
    }

    // 5. Comprehensive email regex validation
    // This regex validates:
    // - Local part (before @): letters, numbers, dots, hyphens, underscores
    // - Domain part (after @): letters, numbers, hyphens
    // - TLD (top-level domain): at least 2 letters
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // 6. Check for consecutive dots
    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    // 7. Check for @ position (not at start or end)
    if (email.startsWith('@') || email.endsWith('@')) {
      return 'Email cannot start or end with @';
    }

    // 8. Check for dot position (not right after @)
    if (email.contains('@.') || email.contains('.@')) {
      return 'Invalid email format';
    }

    // 9. Check for spaces
    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // 10. Check if domain has at least one dot after @
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Email must have exactly one @ symbol';
    }

    final domain = parts[1];
    if (!domain.contains('.')) {
      return 'Invalid domain format';
    }

    // 11. Check domain extension length
    final domainParts = domain.split('.');
    final extension = domainParts.last;
    if (extension.length < 2) {
      return 'Invalid domain extension';
    }

    // All validations passed ✅
    return null;
  }

  /// ✅ Email Input Formatter
  /// Returns true if character is allowed in email
  static bool isValidEmailCharacter(String char) {
    final validCharsRegex = RegExp(r'^[a-zA-Z0-9@._+-]$');
    return validCharsRegex.hasMatch(char);
  }

  /// ✅ Quick email format check (for real-time validation)
  /// Returns true if email looks valid (less strict)
  static bool isEmailFormatValid(String email) {
    if (email.trim().isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// ✅ Common email domains check (optional feature)
  static List<String> getCommonEmailDomains() {
    return [
      '@gmail.com',
      '@yahoo.com',
      '@outlook.com',
      '@hotmail.com',
      '@icloud.com',
      '@protonmail.com',
    ];
  }

  /// ✅ Suggest email correction (optional feature)
  /// Returns suggestion if email looks like it has a typo
  static String? suggestEmailCorrection(String email) {
    if (email.isEmpty) return null;

    final commonTypos = {
      'gmial': 'gmail',
      'gmai': 'gmail',
      'yahooo': 'yahoo',
      'outlok': 'outlook',
      'hotmial': 'hotmail',
    };

    for (var typo in commonTypos.keys) {
      if (email.toLowerCase().contains(typo)) {
        return email.toLowerCase().replaceAll(typo, commonTypos[typo]!);
      }
    }

    return null;
  }
}

