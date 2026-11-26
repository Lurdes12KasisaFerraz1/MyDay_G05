import 'package:flutter/material.dart';

import '../../controllers/community_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../widgets/choice_tabs.dart';
import '../widgets/post_card.dart';
import '../widgets/round_icon_button.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key, required this.communityController, required this.onBack});

  final CommunityController communityController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: communityController,
      builder: (context, _) {
        final posts = communityController.posts;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar ao Diário', onPressed: onBack),
                const SizedBox(width: 12),
                Image.asset(AppImages.logoIcon, height: 30),
                const SizedBox(width: 10),
                Expanded(child: Text('Comunidade', style: Theme.of(context).textTheme.headlineMedium)),
                RoundIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  tooltip: 'Mensagens',
                  onPressed: () => showNotAvailable(context, 'O ecrã de mensagens'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: communityController.search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pessoas, projetos, tags…',
                hintStyle: const TextStyle(color: AppColors.textSubtle),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle),
                filled: true,
                fillColor: AppColors.glass,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ChoiceTabs<CommunityFeed>(
              options: CommunityFeed.values,
              selected: communityController.feed,
              labelOf: (feed) => feed.label,
              onSelected: communityController.setFeed,
            ),
            const SizedBox(height: 16),
            _ChallengeBanner(
              challenge: communityController.weeklyChallenge,
              onParticipate: () => Navigator.pushNamed(context, AppRoutes.newEntry),
            ),
            const SizedBox(height: 14),
            if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Não há publicações para mostrar.', style: TextStyle(color: AppColors.textMuted)),
              ),
            for (final post in posts) ...[
              PostCard(
                post: post,
                onFavorite: () => communityController.toggleFavorite(post),
                onComments: () => showNotAvailable(context, 'Os comentários da comunidade'),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class _ChallengeBanner extends StatelessWidget {
  const _ChallengeBanner({required this.challenge, required this.onParticipate});

  final String challenge;
  final VoidCallback onParticipate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 148,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppImages.classroom, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xF50B0B0E), Color(0xBF0B0B0E), Color(0x260B0B0E)],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Desafio da semana',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3D2800)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challenge,
                      style: const TextStyle(fontSize: 17, height: 1.3, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: FilledButton(
                        onPressed: onParticipate,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Participar'),
                      ),
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
