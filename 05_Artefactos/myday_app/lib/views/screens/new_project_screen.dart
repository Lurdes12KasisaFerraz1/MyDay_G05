import 'package:flutter/material.dart';

import '../../controllers/project_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/photo_picker.dart';
import '../widgets/round_icon_button.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key, required this.projectController});

  final ProjectController projectController;

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  /// Tamanho de prj_nome na base de dados.
  static const int _nameMaxLength = 40;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  Subject _subject = Subject.mathematics;
  EntryVisibility _visibility = EntryVisibility.private;

  /// Sem capa escolhida, usa-se a imagem da disciplina.
  String? _coverImage;

  String get _cover => _coverImage ?? AppImages.forSubject(_subject);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseCover() async {
    final path = await showPhotoPicker(context, selected: _coverImage, title: 'Capa do projeto');
    if (path != null) setState(() => _coverImage = path);
  }

  void _create() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      showInvalidFormAlert(context);
      return;
    }

    try {
      final project = widget.projectController.createProject(
        name: _nameController.text,
        description: _descriptionController.text,
        subject: _subject,
        visibility: _visibility,
        coverImage: _cover,
      );
      showMessage(context, 'Projeto criado. Já podes adicionar registos.');
      Navigator.pushReplacementNamed(context, AppRoutes.projectDetail, arguments: project);
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Text('Novo projeto', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
                const SizedBox(height: 20),
                _CoverPreview(imagePath: _cover, onTap: _chooseCover),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Nome',
                  hint: 'Ex.: Física I',
                  icon: Icons.folder_outlined,
                  controller: _nameController,
                  maxLength: _nameMaxLength,
                  isRequired: true,
                  validator: (value) => Validators.requiredField(value, 'Dá um nome ao projeto'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Descrição',
                  hint: 'Sobre o que vais registar neste projeto?',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                Text('Disciplina', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final subject in Subject.values)
                      ChoiceChip(
                        label: Text(subject.label),
                        selected: subject == _subject,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _subject = subject),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.glass,
                        side: const BorderSide(color: AppColors.glassBorder),
                        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Quem pode ver', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<EntryVisibility>(
                  segments: [
                    for (final visibility in EntryVisibility.values)
                      ButtonSegment(value: visibility, label: Text(visibility.label)),
                  ],
                  selected: {_visibility},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => setState(() => _visibility = selection.first),
                  style: SegmentedButton.styleFrom(
                    backgroundColor: AppColors.glass,
                    foregroundColor: AppColors.textSecondary,
                    selectedBackgroundColor: const Color(0x29FFFFFF),
                    selectedForegroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                ),
                const SizedBox(height: 26),
                GradientButton(label: 'Criar projeto', showArrow: true, onPressed: _create),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.imagePath, required this.onTap});

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Image.asset(imagePath, height: 160, width: double.infinity, fit: BoxFit.cover),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xCC0B0B0E), borderRadius: BorderRadius.circular(999)),
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Mudar capa',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
