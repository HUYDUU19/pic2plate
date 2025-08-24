import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pic_2_plate_ai/domain/cubit/meal/meal_cubit.dart';
import 'package:pic_2_plate_ai/domain/repository/meal_repository.dart';

class GeminiMealRepository extends AbstractMealRepository {
  final apiKey = dotenv.env['PALM_API_KEY'];

  @override
  Future<List<String>> getMeals(MealSettingsParameters parameters) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return ['Error: API key not configured. Please check your .env file.'];
    }

    print('Using API key: ${apiKey!.substring(0, 10)}...');

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey!,
    );

    final prompt = _generatePrompt(parameters);

    try {
      late final GenerateContentResponse response;

      if (parameters.pictures != null && parameters.pictures!.isNotEmpty) {
        // Use multiple images generation
        final List<DataPart> imageParts = [];
        for (final picture in parameters.pictures!) {
          final image = await picture.readAsBytes();
          final mimetype = picture.mimeType ?? 'image/jpeg';
          imageParts.add(DataPart(mimetype, image));
        }

        response = await model.generateContent([
          Content.multi([TextPart(prompt), ...imageParts])
        ]);
      } else if (parameters.picture != null) {
        // Use single image generation (backward compatibility)
        final image = await parameters.picture!.readAsBytes();
        final mimetype = parameters.picture!.mimeType ?? 'image/jpeg';

        response = await model.generateContent([
          Content.multi([TextPart(prompt), DataPart(mimetype, image)])
        ]);
      } else {
        // Use text-only generation
        response = await model.generateContent([Content.text(prompt)]);
      }

      if (response.text != null) {
        return [response.text!];
      } else {
        print('Error: No response text received');
        return ['Error: Could not generate recipe. Please try again.'];
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return ['Error: ${e.toString()}'];
    }
  }

  String _generatePrompt(MealSettingsParameters parameters) {
    // Detect language from user input
    String detectedLanguage = _detectLanguage(parameters);
    String languageInstruction = _getLanguageInstruction(detectedLanguage);

    String prompt;

    if (parameters.pictures != null && parameters.pictures!.isNotEmpty) {
      // Multiple images prompt
      prompt =
          '''You are a very experienced diet Planner. I will provide you with ${parameters.pictures!.length} separate images of different ingredients. Please analyze ALL images together and create 3 meal options using the ingredients shown across all images. 
I need the receipt step by step to easily understand it and format me using only markdown. 
I want the quantity of the ingredients for ${parameters.people.toString()} people and I only want to spend a maximum of ${parameters.maxTimeCooking.toString()} minutes to make the meal.

$languageInstruction
''';
    } else if (parameters.picture != null) {
      // Single image prompt
      prompt =
          '''You are a very experienced diet Planner. I want to have a 3 options for a meal using only the ingredients in the picture. 
I need the receipt step by step to easily understand it and format me using only markdown. 
I want the quantity of the ingredients for ${parameters.people.toString()} people and I only want to spend a maximum of ${parameters.maxTimeCooking.toString()} minutes to make the meal.

$languageInstruction
''';
    } else {
      // Text-based prompt
      prompt =
          '''You are a very experienced diet Planner. I want to have a 3 options for a meal using only the following ingredients: ${parameters.ingredientsText}. 
I need the receipt step by step to easily understand it and format me using only markdown. 
I want the quantity of the ingredients for ${parameters.people.toString()} people and I only want to spend a maximum of ${parameters.maxTimeCooking.toString()} minutes to make the meal.

$languageInstruction
''';
    }

    if (parameters.intoleranceOrLimits != null) {
      prompt +=
          '\nI have the following intolerances or limits: ${parameters.intoleranceOrLimits}';
    }

    return prompt;
  }

  String _detectLanguage(MealSettingsParameters parameters) {
    // Check for Vietnamese characters or common Vietnamese words
    String textToCheck = '';

    if (parameters.ingredientsText != null) {
      textToCheck += parameters.ingredientsText!;
    }

    if (parameters.intoleranceOrLimits != null) {
      textToCheck += ' ${parameters.intoleranceOrLimits!}';
    }

    // Vietnamese detection patterns
    if (textToCheck.contains(RegExp(
            r'[àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ]')) ||
        _containsVietnameseWords(textToCheck.toLowerCase())) {
      return 'vietnamese';
    }

    return 'english';
  }

  bool _containsVietnameseWords(String text) {
    List<String> vietnameseWords = [
      'thit',
      'heo',
      'bo',
      'ga',
      'ca',
      'tom',
      'cua',
      'oc',
      'rau',
      'cai',
      'hanh',
      'toi',
      'gung',
      'ot',
      'nuoc',
      'mam',
      'tuong',
      'dau',
      'gao',
      'bun',
      'mien',
      'banh',
      'pho',
      'xoi',
      'nem',
      'cha',
      'thich',
      'khong',
      'an',
      'uong',
      'nau',
      'lam',
      'voi',
      'toi',
      'co',
      'ban',
      'mon',
      'ngon'
    ];

    return vietnameseWords.any((word) => text.contains(word));
  }

  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'vietnamese':
        return '''QUAN TRỌNG: Vui lòng trả lời hoàn toàn bằng tiếng Việt. Bao gồm tên món ăn, nguyên liệu, và các bước nấu ăn. Sử dụng đơn vị đo lường Việt Nam (gram, kg, thìa, chén, etc.).''';
      default:
        return '''IMPORTANT: Please respond entirely in English with step-by-step cooking instructions.''';
    }
  }
}