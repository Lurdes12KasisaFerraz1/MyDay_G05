import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import 'choice_tabs.dart';

/// Abre a folha de fotografias e devolve o caminho escolhido (ou null).
Future<String?> showPhotoPicker(BuildContext context, {String? selected, String title = 'Escolher fotografia'}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (_) => _PhotoPicker(selected: selected, title: title),
  );
}

/// Folha para escolher uma fotografia, organizada por categoria.
class _PhotoPicker extends StatefulWidget {
  const _PhotoPicker({this.selected, required this.title});

  final String? selected;
  final String title;

  @override
  State<_PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<_PhotoPicker> {
  ImageCategory _category = ImageCategory.values.first;

  @override
  Widget build(BuildContext context) {
    final images = AppImages.byCategory[_category] ?? const [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            ChoiceTabs<ImageCategory>(
              options: ImageCategory.values,
              selected: _category,
              labelOf: (category) => category.label,
              onSelected: (category) => setState(() => _category = category),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final path in images)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context, path),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: path == widget.selected ? AppColors.primaryLight : Colors.transparent,
                          width: 2,
                        ),
                        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
