import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/errors/failures.dart';

part 'form_state.freezed.dart';

/// State for forms with validation
///
/// Manages form state including:
/// - Validation errors
/// - Submission state
/// - Form data
@freezed
class FormState<T> with _$FormState<T> {
  const factory FormState({
    T? data,
    @Default({}) Map<String, String> validationErrors,
    @Default(false) bool isSubmitting,
    @Default(false) bool isValid,
    Failure? submissionError,
    @Default(false) bool submittedSuccessfully,
  }) = _FormState<T>;

  const FormState._();

  /// Check if form has any validation errors
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  /// Check if form can be submitted
  bool get canSubmit => isValid && !isSubmitting && !hasValidationErrors;

  /// Get error for a specific field
  String? getFieldError(String fieldName) => validationErrors[fieldName];

  /// Check if a specific field has error
  bool hasFieldError(String fieldName) => validationErrors.containsKey(fieldName);

  /// Update form data
  FormState<T> updateData(T newData) {
    return copyWith(data: newData);
  }

  /// Set validation error for a field
  FormState<T> setFieldError(String fieldName, String error) {
    final newErrors = Map<String, String>.from(validationErrors);
    newErrors[fieldName] = error;
    return copyWith(
      validationErrors: newErrors,
      isValid: false,
    );
  }

  /// Clear validation error for a field
  FormState<T> clearFieldError(String fieldName) {
    final newErrors = Map<String, String>.from(validationErrors);
    newErrors.remove(fieldName);
    return copyWith(
      validationErrors: newErrors,
      isValid: newErrors.isEmpty,
    );
  }

  /// Clear all validation errors
  FormState<T> clearAllErrors() {
    return copyWith(
      validationErrors: {},
      isValid: true,
      submissionError: null,
    );
  }

  /// Set submitting state
  FormState<T> setSubmitting() {
    return copyWith(
      isSubmitting: true,
      submissionError: null,
      submittedSuccessfully: false,
    );
  }

  /// Set submission success
  FormState<T> setSubmissionSuccess() {
    return copyWith(
      isSubmitting: false,
      submittedSuccessfully: true,
      submissionError: null,
    );
  }

  /// Set submission error
  FormState<T> setSubmissionError(Failure failure) {
    return copyWith(
      isSubmitting: false,
      submissionError: failure,
      submittedSuccessfully: false,
    );
  }

  /// Reset form to initial state
  FormState<T> reset() {
    return FormState<T>(data: data);
  }
}
