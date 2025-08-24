part of 'meal_cubit.dart';

@immutable
sealed class MealState {}

enum InputMode { none, textInput, singleImage, multiImages }

final class MealSettingsParameters extends MealState {
  final int people;
  final int maxTimeCooking;
  final String? intoleranceOrLimits;
  final XFile? picture; // Keep for backward compatibility
  final List<XFile>? pictures; // New: Multiple images support
  final String? ingredientsText;
  final InputMode inputMode; // Track current input mode

  MealSettingsParameters({
    required this.people,
    required this.maxTimeCooking,
    required this.intoleranceOrLimits,
    this.picture, // Legacy single image
    this.pictures, // New multiple images
    this.ingredientsText,
    this.inputMode = InputMode.none, // Default to none
  });

  MealSettingsParameters copyWith({
    int? people,
    int? maxTimeCooking,
    String? intoleranceOrLimits,
    XFile? picture,
    List<XFile>? pictures,
    String? ingredientsText,
    InputMode? inputMode,
  }) =>
      MealSettingsParameters(
        people: people ?? this.people,
        maxTimeCooking: maxTimeCooking ?? this.maxTimeCooking,
        intoleranceOrLimits: intoleranceOrLimits ?? this.intoleranceOrLimits,
        picture: picture ?? this.picture,
        pictures: pictures ?? this.pictures,
        ingredientsText: ingredientsText ?? this.ingredientsText,
        inputMode: inputMode ?? this.inputMode,
      );

  bool isReadyToGenerate() =>
      picture != null ||
      (pictures != null && pictures!.isNotEmpty) ||
      (ingredientsText != null && ingredientsText!.isNotEmpty);

  @override
  String toString() {
    return 'MealSettingsParameters(people: $people, maxTimeCooking: $maxTimeCooking, intoleranceOrLimits: $intoleranceOrLimits, picture: $picture, pictures: ${pictures?.length ?? 0} images, ingredientsText: $ingredientsText, inputMode: $inputMode)';
  }
}

final class MealLoading extends MealState {}

final class MealLoaded extends MealState {
  final List<String> meals;

  MealLoaded({required this.meals});

  @override
  String toString() => 'MealLoaded(meals: $meals)';
}

final class ErrorState extends MealState {
  final dynamic error;

  ErrorState(this.error);

  @override
  String toString() => 'MealError(message: $error)';
}