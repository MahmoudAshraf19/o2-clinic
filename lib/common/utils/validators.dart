/// A utility class containing generic form validation logic.
/// 
/// **Purpose:**
/// Centralizes all validation rules (e.g., Email format, Password length, Required fields)
/// used inside TextFormFields. This ensures validation rules are strictly consistent across 
/// all forms (Login, Register, Edit Profile, etc.) and makes them easy to maintain.
/// 
/// **Usage Example:**
/// ```dart
/// TextFormField(
///   validator: (value) => Validators.validateEmail(value),
///   // or
///   validator: (value) => Validators.validateRequired(value, 'First Name'),
/// )
/// ```
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 9) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
