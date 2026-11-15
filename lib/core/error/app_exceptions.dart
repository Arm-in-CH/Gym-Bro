/// Base exception class for all domain and infrastructure errors in GymBro.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// 1. Validation errors (invalid input, missing plan, empty sets, negative values).
class ValidationException extends AppException implements ArgumentError {
  const ValidationException(super.message, {super.code, super.details});

  @override
  dynamic get invalidValue => details;

  @override
  String? get name => code;

  @override
  StackTrace? get stackTrace => null;

  factory ValidationException.emptyWorkout([String? message]) =>
      ValidationException(
        message ?? 'امکان ثبت جلسه تمرین بدون ست تکمیل‌شده وجود ندارد.',
        code: 'EMPTY_WORKOUT',
      );

  factory ValidationException.missingPlan([String? message]) =>
      ValidationException(
        message ?? 'برنامه تمرینی نامعتبر است یا یافت نشد.',
        code: 'MISSING_PLAN',
      );

  factory ValidationException.invalidSets(String reason) =>
      ValidationException(
        'اطلاعات ست‌های تمرین نامعتبر است: $reason',
        code: 'INVALID_SETS',
      );
}

/// 2. Invalid state transitions (starting already active workout, duplicate completion, etc.).
class StateTransitionException extends AppException {
  const StateTransitionException(super.message, {super.code, super.details});

  factory StateTransitionException.alreadyCompleting() =>
      const StateTransitionException(
        'عملیات ثبت تمرین در حال انجام است؛ لطفاً شکیبا باشید.',
        code: 'ALREADY_COMPLETING',
      );

  factory StateTransitionException.alreadyCompleted() =>
      const StateTransitionException(
        'این جلسه تمرینی قبلاً با موفقیت ثبت شده است.',
        code: 'ALREADY_COMPLETED',
      );

  factory StateTransitionException.invalidTransition(String from, String to) =>
      StateTransitionException(
        'تغییر وضعیت نامعتبر است: از $from به $to.',
        code: 'INVALID_STATE_TRANSITION',
      );
}

/// 3. Storage errors (failed reads/writes, disk error, corruption).
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

/// 4. Network errors (API timeouts, connectivity loss).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// 5. Unexpected internal exceptions (unexpected runtime/state errors).
class InternalException extends AppException {
  const InternalException(super.message, {super.code, super.details});
}
