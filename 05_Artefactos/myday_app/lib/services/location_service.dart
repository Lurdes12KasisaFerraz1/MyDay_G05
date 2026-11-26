import 'package:geolocator/geolocator.dart';

import '../utils/app_exception.dart';

/// Obtém a posição atual do telemóvel através do GPS.
class LocationService {
  static const String _title = 'Localização indisponível';

  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const AppException('Liga a localização do telemóvel e tenta outra vez.', title: _title);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const AppException('Sem autorização, o MyDay não consegue saber onde estás.', title: _title);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        'A localização foi bloqueada para o MyDay. Podes autorizá-la nas definições do telemóvel.',
        title: _title,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on Exception {
      throw const AppException('Não foi possível obter a posição. Tenta num sítio com melhor sinal.', title: _title);
    }
  }
}
