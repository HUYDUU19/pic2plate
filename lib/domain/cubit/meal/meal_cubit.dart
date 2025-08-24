import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:pic_2_plate_ai/domain/repository/meal_repository.dart';

part 'meal_state.dart';

class MealCubit extends Cubit<MealState> {
  static final initialState = MealSettingsParameters(
    people: 1,
    maxTimeCooking: 15,
    intoleranceOrLimits: null,
    picture: null,
    pictures: null,
    ingredientsText: null,
    inputMode: InputMode.none,
  );

  final AbstractMealRepository mealRepository;

  MealCubit(this.mealRepository) : super(initialState);

  void load() {
    emit(initialState);
  }

  void setPeople(int people) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(people: people));

        break;
      default:
    }
  }

  void setMaxTimeCooking(int maxTimeCooking) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters)
            .copyWith(maxTimeCooking: maxTimeCooking));
        break;
      default:
    }
  }

  // set intolerances
  void setIntolerances(String intolerances) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(
            intoleranceOrLimits: intolerances.isEmpty ? null : intolerances));

        break;
      default:
    }
  }

  // set picture (single - for backward compatibility)
  void setPicture(XFile? image) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(
          picture: image,
          pictures: null, // Clear multiple when single is set
          inputMode: image != null ? InputMode.singleImage : InputMode.none,
        ));
        break;
      default:
    }
  }

  // set multiple pictures
  void setPictures(List<XFile>? images) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(
          pictures: images,
          picture: null, // Clear single when multiple is set
          inputMode: images != null ? InputMode.multiImages : InputMode.none,
        ));
        break;
      default:
    }
  }

  // add picture to list
  void addPicture(XFile image) {
    switch (state) {
      case MealSettingsParameters():
        final currentState = state as MealSettingsParameters;
        final currentPictures = currentState.pictures ?? [];
        final newPictures = [...currentPictures, image];
        emit(currentState.copyWith(
          pictures: newPictures,
          picture: null, // Clear single image when adding to multiple
          inputMode: InputMode.multiImages,
        ));
        break;
      default:
    }
  }

  // remove picture from list
  void removePicture(int index) {
    switch (state) {
      case MealSettingsParameters():
        final currentState = state as MealSettingsParameters;
        if (currentState.pictures != null &&
            index < currentState.pictures!.length) {
          final newPictures = [...currentState.pictures!];
          newPictures.removeAt(index);
          final updatedPictures = newPictures.isEmpty ? null : newPictures;
          emit(currentState.copyWith(
            pictures: updatedPictures,
            inputMode: updatedPictures != null ? InputMode.multiImages : InputMode.none,
          ));
        }
        break;
      default:
    }
  }

  // clear picture(s)
  void clearPicture() {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(
          picture: null,
          pictures: null,
          inputMode: InputMode.none,
        ));
        break;
      default:
    }
  }

  // set ingredients text
  void setIngredientsText(String? text) {
    switch (state) {
      case MealSettingsParameters():
        final cleanText = text?.isEmpty == true ? null : text;
        emit((state as MealSettingsParameters).copyWith(
          ingredientsText: cleanText,
          inputMode: cleanText != null ? InputMode.textInput : InputMode.none,
        ));
        break;
      default:
    }
  }

  // set input mode explicitly
  void setInputMode(InputMode mode) {
    switch (state) {
      case MealSettingsParameters():
        emit((state as MealSettingsParameters).copyWith(
          inputMode: mode,
        ));
        break;
      default:
    }
  }

  void getMeal() async {
    switch (state) {
      case MealSettingsParameters():
        try {
          final mealParameters = state as MealSettingsParameters;
          emit(MealLoading());
          final meals = await mealRepository.getMeals(mealParameters);
          emit(MealLoaded(meals: meals));
        } catch (e) {
          emit(ErrorState(e));
        }

        break;
      default:
    }
  }
}