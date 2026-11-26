import 'package:flutter/material.dart';

import '../../controllers/diary_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/photo_picker.dart';
import '../widgets/round_icon_button.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({
    super.key,
    required this.diaryController,
    required this.settingsController,
    this.initialProject,
  });

  final DiaryController diaryController;
  final SettingsController settingsController;

  /// Projeto já escolhido quando o registo é criado a partir do projeto.
  final String? initialProject;

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _tagsController = TextEditingController();

  late String _project = widget.initialProject ?? widget.diaryController.projectNames.first;

  // A disciplina vem do projeto (prj_dis_id), mas pode ser trocada.
  late Subject _subject = _subjectOf(_project);
  EntryVisibility _visibility = EntryVisibility.private;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  AttachmentType? _media;
  String? _imagePath;
  ({double latitude, double longitude})? _location;
  bool _isLocating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Subject _subjectOf(String projectName) {
    return widget.diaryController.projectNamed(projectName)?.subject ?? Subject.mathematics;
  }

  Future<void> _selectAttachment(AttachmentType type) async {
    switch (type) {
      case AttachmentType.photo:
        await _choosePhoto();
      case AttachmentType.location:
        await _toggleLocation();
      case AttachmentType.video:
      case AttachmentType.audio:
        setState(() => _media = _media == type ? null : type);
    }
  }

  Future<void> _choosePhoto() async {
    final path = await showPhotoPicker(context, selected: _imagePath);
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _toggleLocation() async {
    if (_location != null) {
      setState(() => _location = null);
      return;
    }
    if (!widget.settingsController.locationEnabled) {
      await showAlert(
        context,
        title: 'Localização desligada',
        message: 'Ativa a localização no Perfil, em Privacidade e permissões, para juntar o local ao registo.',
      );
      return;
    }

    setState(() => _isLocating = true);
    try {
      final location = await widget.diaryController.currentLocation();
      if (mounted) setState(() => _location = location);
    } on AppException catch (error) {
      if (mounted) await showErrorAlert(context, error);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  String? get _locationLabel {
    final location = _location;
    if (location == null) return null;
    return '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(RegExp(r'[\s,]+'))
        .map((tag) => tag.replaceAll('#', '').trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      showInvalidFormAlert(context);
      return;
    }

    final entry = widget.diaryController.addEntry(
      title: _titleController.text,
      text: _textController.text,
      subject: _subject,
      project: _project,
      visibility: _visibility,
      tags: _parseTags(),
      location: _locationLabel,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
      imagePath: _imagePath,
      mediaType: _media,
    );
    showMessage(context, 'Registo guardado.');
    Navigator.pushReplacementNamed(context, AppRoutes.entryDetail, arguments: entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => Navigator.maybePop(context), onSave: _save),
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      AppTextField(
                        label: 'Título',
                        hint: 'Ex.: Derivadas: regra da cadeia',
                        controller: _titleController,
                        isRequired: true,
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                        validator: (value) => Validators.requiredField(value, 'Dá um título ao registo'),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'O que aprendeste hoje?',
                        hint: 'Escreve o que percebeste, as dúvidas ou o próximo passo.',
                        controller: _textController,
                        maxLines: 4,
                        isRequired: true,
                        validator: (value) => Validators.requiredField(value, 'Escreve o que aprendeste'),
                      ),
                      const SizedBox(height: 16),
                      _AttachmentButtons(
                        selected: {
                          if (_imagePath != null) AttachmentType.photo,
                          if (_media != null) _media!,
                          if (_location != null) AttachmentType.location,
                        },
                        loading: _isLocating ? AttachmentType.location : null,
                        onTap: _selectAttachment,
                      ),
                      if (_imagePath != null) ...[
                        const SizedBox(height: 12),
                        _PhotoPreview(
                          imagePath: _imagePath!,
                          onRemove: () => setState(() => _imagePath = null),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _OptionsCard(
                        location: _isLocating ? 'A obter posição…' : _locationLabel ?? 'Sem local',
                        subject: _subject,
                        project: _project,
                        projects: widget.diaryController.projectNames,
                        onSubjectChanged: (subject) => setState(() => _subject = subject),
                        onProjectChanged: (project) => setState(() {
                          _project = project;
                          _subject = _subjectOf(project);
                        }),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Tags',
                        hint: '#derivadas #cálculo',
                        icon: Icons.tag_rounded,
                        controller: _tagsController,
                      ),
                      const SizedBox(height: 18),
                      _VisibilitySelector(
                        selected: _visibility,
                        onChanged: (visibility) => setState(() => _visibility = visibility),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onSave});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar', onPressed: onBack),
          const Expanded(
            child: Text(
              'Novo registo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          GradientButton(label: 'Guardar', height: 40, expand: false, onPressed: onSave),
        ],
      ),
    );
  }
}

class _AttachmentButtons extends StatelessWidget {
  const _AttachmentButtons({required this.selected, required this.onTap, this.loading});

  final Set<AttachmentType> selected;
  final AttachmentType? loading;
  final ValueChanged<AttachmentType> onTap;

  static const Map<AttachmentType, IconData> _icons = {
    AttachmentType.photo: Icons.photo_camera_outlined,
    AttachmentType.video: Icons.videocam_outlined,
    AttachmentType.audio: Icons.mic_none_rounded,
    AttachmentType.location: Icons.place_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in AttachmentType.values) ...[
          Expanded(
            child: _AttachmentButton(
              label: type.label,
              icon: _icons[type]!,
              isSelected: selected.contains(type),
              isLoading: loading == type,
              onTap: () => onTap(type),
            ),
          ),
          if (type != AttachmentType.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : AppColors.textSecondary;

    return Material(
      color: isSelected ? const Color(0x2E3A93FF) : AppColors.glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.primaryLight : AppColors.glassBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.imagePath, required this.onRemove});

  final String imagePath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Image.asset(imagePath, height: 150, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            top: 8,
            right: 8,
            child: RoundIconButton(icon: Icons.close_rounded, tooltip: 'Remover fotografia', onPressed: onRemove),
          ),
        ],
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.location,
    required this.subject,
    required this.project,
    required this.projects,
    required this.onSubjectChanged,
    required this.onProjectChanged,
  });

  final String location;
  final Subject subject;
  final String project;
  final List<String> projects;
  final ValueChanged<Subject> onSubjectChanged;
  final ValueChanged<String> onProjectChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _OptionRow(label: 'Local', value: location),
          _OptionRow(
            label: 'Disciplina',
            value: subject.label,
            onTap: () => _choose<Subject>(
              context,
              title: 'Disciplina',
              options: Subject.values,
              labelOf: (option) => option.label,
              onSelected: onSubjectChanged,
            ),
          ),
          _OptionRow(
            label: 'Projeto',
            value: project,
            showDivider: false,
            onTap: () => _choose<String>(
              context,
              title: 'Projeto',
              options: projects,
              labelOf: (option) => option,
              onSelected: onProjectChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _choose<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T option) labelOf,
    required ValueChanged<T> onSelected,
  }) async {
    final choice = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            for (final option in options)
              ListTile(
                title: Text(labelOf(option), style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(sheetContext, option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) onSelected(choice);
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.label, required this.value, this.onTap, this.showDivider = true});

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: showDivider ? const Border(bottom: BorderSide(color: AppColors.surfaceBorder)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

class _VisibilitySelector extends StatelessWidget {
  const _VisibilitySelector({required this.selected, required this.onChanged});

  final EntryVisibility selected;
  final ValueChanged<EntryVisibility> onChanged;

  String get _hint {
    return switch (selected) {
      EntryVisibility.private => 'Só tu vês este registo.',
      EntryVisibility.friends => 'Os teus amigos podem ver e comentar.',
      EntryVisibility.public => 'Qualquer pessoa na comunidade pode ver.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quem pode ver',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 8),
        SegmentedButton<EntryVisibility>(
          segments: [
            for (final visibility in EntryVisibility.values)
              ButtonSegment(value: visibility, label: Text(visibility.label)),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.glass,
            foregroundColor: AppColors.textSecondary,
            selectedBackgroundColor: const Color(0x29FFFFFF),
            selectedForegroundColor: Colors.white,
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        ),
        const SizedBox(height: 8),
        Text(_hint, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
