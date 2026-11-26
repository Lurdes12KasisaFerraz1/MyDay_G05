import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/diary_controller.dart';
import '../../models/entry.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../widgets/entry_card.dart';
import '../widgets/round_icon_button.dart';

/// Mapa com os registos que têm localização GPS.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.diaryController, this.focusEntry});

  final DiaryController diaryController;

  /// Registo a destacar quando o mapa abre a partir do detalhe.
  final Entry? focusEntry;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Usado quando ainda não há registos com localização.
  static const LatLng _iade = LatLng(38.70735, -9.15265);

  late Entry? _selected = widget.focusEntry;

  LatLng _pointOf(Entry entry) => LatLng(entry.latitude!, entry.longitude!);

  @override
  Widget build(BuildContext context) {
    final entries = widget.diaryController.entriesWithLocation;
    final selected = _selected;
    final center = selected != null
        ? _pointOf(selected)
        : (entries.isEmpty ? _iade : _pointOf(entries.first));

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: selected != null ? 17 : 15,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pt.iade.myday',
              ),
              MarkerLayer(
                markers: [
                  for (final entry in entries)
                    Marker(
                      point: _pointOf(entry),
                      width: 52,
                      height: 52,
                      child: _EntryMarker(
                        entry: entry,
                        isSelected: entry == selected,
                        onTap: () => setState(() => _selected = entry),
                      ),
                    ),
                ],
              ),
              const SimpleAttributionWidget(source: Text('OpenStreetMap')),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.navBar, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      entries.length == 1 ? '1 registo no mapa' : '${entries.length} registos no mapa',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: SafeArea(
                child: EntryCard(
                  entry: selected,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: selected),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryMarker extends StatelessWidget {
  const _EntryMarker({required this.entry, required this.isSelected, required this.onTap});

  final Entry entry;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imagePath = entry.imagePath;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.gold : Colors.white,
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: imagePath == null ? null : AssetImage(imagePath),
          child: imagePath == null ? const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20) : null,
        ),
      ),
    );
  }
}
