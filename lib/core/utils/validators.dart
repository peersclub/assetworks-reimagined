class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  // Password strength validation
  static bool isStrongPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;
    
    // Contains uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Contains lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Contains number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Contains special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }
  
  // Password strength level
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }
  
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      case 6:
        return 'Very Strong';
      default:
        return 'Unknown';
    }
  }
  
  // Name validation
  static bool isValidName(String name) {
    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    return nameRegex.hasMatch(name) && name.trim().length >= 2;
  }
  
  // Phone validation
  static bool isValidPhone(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    // Check if it's a valid phone number (10-15 digits)
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }
  
  // Username validation
  static bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }
  
  // URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // Credit card validation (Luhn algorithm)
  static bool isValidCreditCard(String cardNumber) {
    // Remove spaces and non-digits
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return false;
    }
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      int digit = int.parse(digitsOnly[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  // CVV validation
  static bool isValidCVV(String cvv) {
    final cvvRegex = RegExp(r'^\d{3,4}$');
    return cvvRegex.hasMatch(cvv);
  }
  
  // Expiry date validation (MM/YY format)
  static bool isValidExpiryDate(String expiry) {
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!expiryRegex.hasMatch(expiry)) {
      return false;
    }
    
    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final expiryDate = DateTime(year, month);
    
    return expiryDate.isAfter(now);
  }
  
  // ZIP code validation
  static bool isValidZipCode(String zipCode) {
    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    return zipRegex.hasMatch(zipCode);
  }
  
  // Stock symbol validation
  static bool isValidStockSymbol(String symbol) {
    final symbolRegex = RegExp(r'^[A-Z]{1,5}$');
    return symbolRegex.hasMatch(symbol);
  }
  
  // Amount validation
  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0 && value <= 1000000; // Max 1 million
    } catch (e) {
      return false;
    }
  }
  
  // Percentage validation
  static bool isValidPercentage(String percentage) {
    try {
      final value = double.parse(percentage);
      return value >= 0 && value <= 100;
    } catch (e) {
      return false;
    }
  }
  
  // File size validation
  static bool isValidFileSize(int sizeInBytes, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return sizeInBytes <= maxSizeInBytes;
  }
  
  // File extension validation
  static bool isValidFileExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  // Date validation
  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Age validation
  static bool isValidAge(DateTime birthDate, {int minAge = 18}) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return age - 1 >= minAge;
    }
    
    return age >= minAge;
  }
  
  // Required field validation
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  // Min length validation
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }
  
  // Max length validation
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }
  
  // Range validation
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }
  
  // Alphanumeric validation
  static bool isAlphanumeric(String value) {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(value);
  }
  
  // Contains only letters
  static bool isAlpha(String value) {
    final alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(value);
  }
  
  // Contains only numbers
  static bool isNumeric(String value) {
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(value);
  }
  
  // Custom regex validation
  static bool matchesPattern(String value, String pattern) {
    final regex = RegExp(pattern);
    return regex.hasMatch(value);
  }
}