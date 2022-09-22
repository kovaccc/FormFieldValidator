import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

abstract class Validator {
  static String? validate(
      String? inputValue, List<ValidationType> validationTypes) {
    List<String?> errorMessages = [];

    for (var validationType in validationTypes) {
      var errorMessage = validationType.isValid(inputValue)
          ? null
          : validationType.errorMessage;
      if (errorMessage != null) {
        errorMessages.add(errorMessage);
      }
    }
    return errorMessages.isEmpty ? null : errorMessages.first;
  }
}

abstract class ValidationType {
  String errorMessage;

  bool isValid(String? inputValue);

  ValidationType(this.errorMessage);
}

class Required extends ValidationType {
  Required(super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    return inputValue != null && inputValue.isNotEmpty;
  }
}

class ValidEmail extends ValidationType {
  ValidEmail(super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    return EmailValidator.validate(inputValue!);
  }
}

class MinLength extends ValidationType {
  final int length;

  MinLength(this.length, super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    return inputValue!.length > length;
  }
}

class MaxLength extends ValidationType {
  final int length;

  MaxLength(this.length, super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    return inputValue!.length < length;
  }
}

class Regex extends ValidationType {
  final String expression;

  Regex(this.expression, super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    return RegExp(expression).hasMatch(inputValue!);
  }
}

class ValidDateFormat extends ValidationType {
  final String dateFormat;

  ValidDateFormat(this.dateFormat, super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    try {
      DateFormat(dateFormat).parseStrict(inputValue!);
      return true;
    } catch (_) {
      return false;
    }
  }
}

enum Years {
  three,
  sixteen,
  eighteen,
}

extension YearsExtension on Years {
  int getYearsInMilliSeconds() {
    int yearsInMillis = 0;
    if (this == Years.three) {
      yearsInMillis = 94670856000;
    } else if (this == Years.sixteen) {
      yearsInMillis = 504911232000;
    } else if (this == Years.eighteen) {
      yearsInMillis = 568025136000;
    }
    return yearsInMillis;
  }
}

class ValidBirthDate extends ValidationType {
  final Years minYears;
  final String dateFormat;

  ValidBirthDate(this.minYears, this.dateFormat, super.errorMessage);

  @override
  bool isValid(String? inputValue) {
    var isValid = true;
    try {
      final dateInMillis =
          DateFormat(dateFormat).parse(inputValue!).millisecondsSinceEpoch;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - dateInMillis < minYears.getYearsInMilliSeconds()) {
        isValid = false;
      }
    } catch (e) {
      errorMessage = "Invalid date format";
      isValid = false;
    }
    return isValid;
  }
}
