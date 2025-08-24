import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_2_plate_ai/domain/cubit/meal/meal_cubit.dart';

class MultiImagePicker extends StatelessWidget {
  const MultiImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealCubit, MealState>(
      builder: (context, state) {
        if (state is! MealSettingsParameters) return Container();

        final pictures = state.pictures ?? [];
        final hasImages = pictures.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredients (${pictures.length}/5)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (hasImages)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<MealCubit>().setPictures(null),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Image grid
            if (hasImages) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: pictures.length,
                itemBuilder: (context, index) {
                  return _ImageItem(
                    image: pictures[index],
                    onRemove: () =>
                        context.read<MealCubit>().removePicture(index),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Add buttons
            Row(
              children: [
                Expanded(
                  child: _AddImageButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onPressed: pictures.length < 5
                        ? () => _pickImage(context, ImageSource.gallery)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddImageButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onPressed: pictures.length < 5
                        ? () => _pickImage(context, ImageSource.camera)
                        : null,
                  ),
                ),
              ],
            ),

            if (pictures.length >= 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '* Maximum 5 ingredient images',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      context.read<MealCubit>().addPicture(image);
      // Clear text when image is added
      context.read<MealCubit>().setIngredientsText(null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select image')),
      );
    }
  }
}

class _ImageItem extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImageItem({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(image.path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _AddImageButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}