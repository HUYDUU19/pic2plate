// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_2_plate_ai/domain/cubit/meal/meal_cubit.dart';
import 'package:pic_2_plate_ai/ui/pages/meal_creation/widgets/multi_image_picker.dart';

class FormMealCreation extends StatefulWidget {
  final MealSettingsParameters state;

  const FormMealCreation({required this.state, super.key});

  @override
  State<FormMealCreation> createState() => _FormMealCreationState();
}

class _FormMealCreationState extends State<FormMealCreation> {
  final ImagePicker picker = ImagePicker();
  late TextEditingController _ingredientsController;

  @override
  void initState() {
    super.initState();
    _ingredientsController =
        TextEditingController(text: widget.state.ingredientsText ?? '');
  }

  @override
  void didUpdateWidget(FormMealCreation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.ingredientsText != oldWidget.state.ingredientsText) {
      _ingredientsController.text = widget.state.ingredientsText ?? '';
    }
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                      "How many people are you cooking for?",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Slider(
                      divisions: 3,
                      label: "${widget.state.people} people",
                      value: widget.state.people.toDouble(),
                      min: 1,
                      max: 4,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (double value) =>
                          context.read<MealCubit>().setPeople(value.toInt()),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "How long do you want to cook?",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    SegmentedButton(
                      multiSelectionEnabled: false,
                      segments: const [
                        ButtonSegment(label: Text("15 m"), value: 15),
                        ButtonSegment(label: Text("30 m"), value: 30),
                        ButtonSegment(label: Text("45 m"), value: 45),
                        ButtonSegment(label: Text("60 m"), value: 60),
                      ],
                      selected: {widget.state.maxTimeCooking},
                      onSelectionChanged: (selections) => context
                          .read<MealCubit>()
                          .setMaxTimeCooking(selections.first),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Food allergies / Food preferences (optional)",
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (String value) =>
                      context.read<MealCubit>().setIntolerances(value),
                ),
                Column(
                  children: [
                    Text(
                      'Describe your ingredients',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16.0),

                    // Text input field - always visible with proper controller
                    TextField(
                      controller: _ingredientsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Ingredients description (optional)",
                        hintText:
                            "Example: I have pork, vegetables, onion, chili, fish sauce, garlic...\nDescribe what ingredients you have available",
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: _ingredientsController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ingredientsController.clear();
                                  context
                                      .read<MealCubit>()
                                      .setIngredientsText(null);
                                },
                              )
                            : null,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (String value) {
                        setState(() {}); // Rebuild to update suffix icon
                        context
                            .read<MealCubit>()
                            .setIngredientsText(value.isEmpty ? null : value);
                        // Clear images when typing
                        if (value.isNotEmpty) {
                          context.read<MealCubit>().clearPicture();
                          context.read<MealCubit>().setPictures(null);
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Status indicator for text input
                    if (widget.state.ingredientsText != null &&
                        widget.state.ingredientsText!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Ingredients description ready ✓',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Photo selection area - always visible when no text input
                    if (widget.state.ingredientsText == null ||
                        widget.state.ingredientsText!.isEmpty) ...[
                      // Multi-image picker - show when pictures array exists (even if empty)
                      if (widget.state.pictures != null)
                        const MultiImagePicker()
                      // Single image display - show when single picture exists
                      else if (widget.state.picture != null) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(widget.state.picture!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                    onPressed: () {
                                      context.read<MealCubit>().clearPicture();
                                    },
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Image selected ✓',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                      ]
                      // Show photo selection info when no images selected
                      else ...[
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Take or upload photos of your ingredients',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),

                        // Enhanced photo buttons with multi-image gallery support
                        Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 64) / 3,
                              child: FilledButton.tonalIcon(
                                icon: const Icon(Icons.photo_library_rounded,
                                    size: 20),
                                onPressed: () async {
                                  // Multi-image picker for gallery
                                  final List<XFile> images =
                                      await picker.pickMultiImage();

                                  if (images.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('No images were selected')),
                                    );
                                    return;
                                  }

                                  // Set to multi-image mode and add all selected images
                                  context.read<MealCubit>().setPictures(images);

                                  // Clear text and single image when multi-images are selected
                                  context
                                      .read<MealCubit>()
                                      .setIngredientsText(null);
                                  _ingredientsController.clear();
                                  context.read<MealCubit>().clearPicture();
                                },
                                label: Text(
                                  "Multiple",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 64) / 3,
                              child: FilledButton.tonalIcon(
                                icon: const Icon(
                                    Icons.photo_size_select_actual_rounded,
                                    size: 20),
                                onPressed: () async {
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (image == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Could not select image')),
                                    );
                                    return;
                                  }

                                  // Single image mode
                                  context.read<MealCubit>().setPicture(image);

                                  // Clear text and multi-images when single image is selected
                                  context
                                      .read<MealCubit>()
                                      .setIngredientsText(null);
                                  _ingredientsController.clear();
                                  context.read<MealCubit>().setPictures(null);
                                },
                                label: Text(
                                  "Gallery",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 64) / 3,
                              child: FilledButton.tonalIcon(
                                label: Text(
                                  "Camera",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                onPressed: () async {
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera);

                                  if (image == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Could not take photo')),
                                    );
                                    return;
                                  }

                                  // Single image mode for camera
                                  context.read<MealCubit>().setPicture(image);

                                  // Clear text and multi-images when camera image is selected
                                  context
                                      .read<MealCubit>()
                                      .setIngredientsText(null);
                                  _ingredientsController.clear();
                                  context.read<MealCubit>().setPictures(null);
                                },
                                icon: const Icon(Icons.camera_alt_rounded,
                                    size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: (widget.state.picture != null ||
                    (widget.state.pictures != null &&
                        widget.state.pictures!.isNotEmpty) ||
                    (widget.state.ingredientsText != null &&
                        widget.state.ingredientsText!.isNotEmpty))
                ? () => context.read<MealCubit>().getMeal()
                : null,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "Generate Recipe",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (widget.state.picture != null ||
                              (widget.state.pictures != null &&
                                  widget.state.pictures!.isNotEmpty) ||
                              (widget.state.ingredientsText != null &&
                                  widget.state.ingredientsText!.isNotEmpty))
                          ? Colors.white
                          : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}