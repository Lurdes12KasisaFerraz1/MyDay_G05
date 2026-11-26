import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/study_group.dart';
import '../../utils/app_colors.dart';
import 'tags.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.entriesCount,
    required this.lastActivity,
    required this.onTap,
  });

  final Project project;
  final int entriesCount;
  final String lastActivity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 108,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(project.coverImage, fit: BoxFit.cover),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: VisibilityBadge(visibility: project.visibility, onImage: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    '${entriesCount == 1 ? '1 registo' : '$entriesCount registos'} · $lastActivity',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyGroupCard extends StatelessWidget {
  const StudyGroupCard({super.key, required this.group, required this.onTap});

  final StudyGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final extraMembers = group.membersCount - group.memberAvatars.length;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 12 + 26.0 * group.memberAvatars.length + (extraMembers > 0 ? 26 : 0),
                height: 38,
                child: Stack(
                  children: [
                    for (var i = 0; i < group.memberAvatars.length; i++)
                      Positioned(left: 26.0 * i, child: _MemberAvatar(imagePath: group.memberAvatars[i])),
                    if (extraMembers > 0)
                      Positioned(
                        left: 26.0 * group.memberAvatars.length,
                        child: _MemberAvatar(label: '+$extraMembers'),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${group.membersCount} membros · ${group.sharedEntries} registos partilhados',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({this.imagePath, this.label});

  final String? imagePath;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF26272E),
        border: Border.all(color: AppColors.surface, width: 2),
        image: imagePath == null
            ? null
            : DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: label == null
          ? null
          : Text(
              label!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
            ),
    );
  }
}
