import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/messages.dart';

/// Folha com o código QR do perfil e um botão para o partilhar.
class ProfileQrSheet extends StatefulWidget {
  const ProfileQrSheet({super.key, required this.user});

  final User user;

  @override
  State<ProfileQrSheet> createState() => _ProfileQrSheetState();
}

class _ProfileQrSheetState extends State<ProfileQrSheet> {
  static const _qrColor = AppColors.background;

  bool _isSharing = false;

  String get _handle => widget.user.email.split('@').first;
  String get _profileLink => 'myday://perfil/$_handle';

  Future<void> _share(Rect origin) async {
    setState(() => _isSharing = true);
    try {
      final image = await QrPainter(
        data: _profileLink,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _qrColor),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: _qrColor),
        emptyColor: Colors.white,
      ).toImageData(600, format: ui.ImageByteFormat.png);
      if (image == null) throw Exception('QR sem dados');

      await SharePlus.instance.share(
        ShareParams(
          text: 'Segue o meu diário no MyDay: $_profileLink',
          files: [XFile.fromData(image.buffer.asUint8List(), mimeType: 'image/png')],
          fileNameOverrides: ['myday_$_handle.png'],
          sharePositionOrigin: origin,
        ),
      );
    } on Exception {
      if (mounted) {
        await showAlert(context, title: 'Não foi possível partilhar', message: 'Tenta outra vez dentro de momentos.');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.glassBorder, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: QrImageView(
                data: _profileLink,
                size: 200,
                padding: EdgeInsets.zero,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _qrColor),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: _qrColor),
                semanticsLabel: 'Código QR do perfil',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text('@$_handle', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Builder(
              builder: (buttonContext) => SizedBox(
                height: 38,
                child: FilledButton.icon(
                  onPressed: _isSharing
                      ? null
                      : () {
                          // No iPad a folha de partilha abre junto ao botão.
                          final box = buttonContext.findRenderObject() as RenderBox?;
                          final origin = box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;
                          _share(origin);
                        },
                  icon: _isSharing
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Partilhar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
